#include "include/camera.cuh"

namespace renderKernelFunctions {
    __device__ color ray_color(const ray& r, hittable** world)
    {
        hit_record rec;
        if ((*world)->hit(r, interval(0, constants::infinity), rec))
        {
            return 0.5f * (rec.normal + color(1, 1, 1));
        }
        vec3 unit_direction = unit_vector(r.get_direction());
        auto a = 0.5f * (unit_direction.y() + 1.0f);
        return (1.0f - a) * color(1.0f, 1.0f, 1.0f) + a * color(0.5f, 0.7f, 1.0f);
    }

    __global__ void render_framebuffer(vec3* d_fb, hittable** d_world, camera_params camParams)
    {
        int i = threadIdx.x + blockDim.x * blockIdx.x; // width
        int j = threadIdx.y + blockDim.y * blockIdx.y; //height

        if (i >= camParams.image_width || j >= camParams.image_height) return;

        int pixel_index = j * camParams.image_width + i;
        auto viewPortPixelIndex = camParams.pixel00_loc + (i * camParams.pixel_delta_u) + (j * camParams.pixel_delta_v);
        auto ray_direction = viewPortPixelIndex - camParams.cameraCenter;
        ray r(camParams.cameraCenter, ray_direction);
        d_fb[pixel_index] = renderKernelFunctions::ray_color(r, d_world);
    }

    __global__ void create_world(hittable** d_list, hittable** d_world)
    {
        if (threadIdx.x == 0 && blockIdx.x == 0)
        {
            *(d_list) = new sphere(point3(0, 0, -1), 0.5f);
            *(d_list + 1) = new sphere(point3(0, -100.5f, -1), 100);
            *d_world = new hittable_list(d_list, 2);
        }
    }

    __global__ void clear_world(hittable** d_list, hittable** d_world)
    {
        if (threadIdx.x == 0 && blockIdx.x == 0)
        {
            delete* (d_list);
            delete* (d_list + 1);
            delete* d_world;
        }
    }
}

void camera::Init()
{
    image_height = static_cast<int>(image_width / aspect_ratio);
    image_height = (image_height < 1) ? 1 : image_height;

    cameraCenter = point3(0, 0, 0);

    float focal_length = 1.0f;
    float viewport_height = 2.0f;
    float viewport_width = viewport_height * (static_cast<float>(image_width) / image_height);

    vec3 viewport_u(viewport_width, 0, 0); // viewport width
    vec3 viewport_v(0, -viewport_height, 0); // viewport height

    pixel_delta_u = viewport_u / image_width;
    pixel_delta_v = viewport_v / image_height;

    vec3 viewport_upper_left = cameraCenter - vec3(0, 0, focal_length) - (viewport_u / 2) - (viewport_v / 2);
    pixel00_loc = viewport_upper_left + 0.5f * (pixel_delta_u + pixel_delta_v);
}

camera::camera()
{
    Init();
    checkCudaErrors(cudaMalloc((void**)&d_list, 2 * sizeof(hittable*)));
    checkCudaErrors(cudaMalloc((void**)&d_world, sizeof(hittable*)));
    renderKernelFunctions::create_world << <1, 1 >> > (d_list, d_world);
    checkCudaErrors(cudaGetLastError());
    checkCudaErrors(cudaDeviceSynchronize());

    checkCudaErrors(cudaMalloc((void**)&d_fb, image_width * image_height * sizeof(vec3)));
}

camera::~camera()
{
    renderKernelFunctions::clear_world << <1, 1 >> > (d_list, d_world);
    checkCudaErrors(cudaGetLastError());
    checkCudaErrors(cudaDeviceSynchronize());
    checkCudaErrors(cudaFree(d_list));
    checkCudaErrors(cudaFree(d_world));
    checkCudaErrors(cudaFree(d_fb));
}

void camera::render() // moze to world powinno sie tworzyc poza klasa ( w mainie)
{
    camera_params camParams;
    camParams.image_width = image_width;
    camParams.image_height = image_height;
    camParams.cameraCenter = cameraCenter;
    camParams.pixel00_loc = pixel00_loc;
    camParams.pixel_delta_u = pixel_delta_u;
    camParams.pixel_delta_v = pixel_delta_v;

    std::vector<vec3> fb(image_width * image_height);

    dim3 blockSize(16, 16);
    dim3 gridSize((image_width + blockSize.x - 1) / blockSize.x, (image_height + blockSize.y - 1) / blockSize.y);
    renderKernelFunctions::render_framebuffer << <gridSize, blockSize >> > (d_fb, d_world, camParams);
    checkCudaErrors(cudaGetLastError());
    checkCudaErrors(cudaDeviceSynchronize());
    checkCudaErrors(cudaMemcpy(fb.data(), d_fb, image_width * image_height * sizeof(vec3), cudaMemcpyDeviceToHost));
    std::cout << "P3\n" << image_width << " " << image_height << "\n255\n";
    for (int j = 0; j < image_height; j++) {
        for (int i = 0; i < image_width; i++) {
            size_t pixel_index = j * image_width + i;
            auto pixel_color = fb[pixel_index];
            write_color(std::cout, pixel_color);
        }
    }
}
