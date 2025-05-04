#include "include/GPU_variables.cuh"
#include "include/camera.cuh"
//#include "include/material.cuh"
#include "include/lambertian.cuh"
#include "include/metal.cuh"

namespace renderKernelFunctions {
    __global__ void init_rand_state(curandState* rand_state, int width, int height)
    {
        int i = threadIdx.x + blockDim.x * blockIdx.x;
        int j = threadIdx.y + blockDim.y * blockIdx.y;

        if (i >= width || j >= height) return;

        int pixel_index = j * width + i;
        curand_init(2025, pixel_index, 0, &rand_state[pixel_index]);
    }
    __device__ color ray_color(const ray& r, hittable** world, curandState *r_state)
    {
        ray cur_ray = r;
        vec3 cur_attenuation = vec3(1.0f, 1.0f,1.0f);
        for (int i = 0; i < 50; i++) {
            hit_record rec;
            if ((*world)->hit(cur_ray, interval(0.0001f, constants::infinity), rec))
            {
                ray scattered;
                vec3 attenutation;
                if (rec.mat_ptr->scatter(cur_ray, rec, attenutation, scattered, r_state)) {
                    cur_attenuation = attenutation * cur_attenuation;
                    cur_ray = scattered;
                }
                else
                {
                    return vec3(0.0f, 0.0f, 0.0f);
                }
				//vec3 direction = rec.normal + random_unit_vec(r_state);
				//cur_attenuation *= 0.5f;
				//cur_ray = ray(rec.p, direction);
            }
            else {
                vec3 unit_direction = unit_vector(r.get_direction());
                float a = 0.5f * (unit_direction.y() + 1.0f);
				vec3 col = (1.0f - a) * color(1.0f, 1.0f, 1.0f) + a * color(0.5f, 0.7f, 1.0f);
                return cur_attenuation * col;
            }
        }
        return vec3(0.0f, 0.0f, 0.0f);
    }

    __global__ void render_framebuffer(vec3* d_fb, hittable** d_world, camera_params camParams, curandState *rand_state)
    {
        int i = threadIdx.x + blockDim.x * blockIdx.x; // width
        int j = threadIdx.y + blockDim.y * blockIdx.y; //height

        if (i >= camParams.image_width || j >= camParams.image_height) return;

        int pixel_index = j * camParams.image_width + i;

        curandState local_rand_state = rand_state[pixel_index];

        vec3 color(0, 0, 0);

        int spp = camParams.samples_per_pixel;

        for (int sample = 0; sample < spp; sample++)
        {
            float x = curand_uniform(&local_rand_state) -0.5f;
            float y = curand_uniform(&local_rand_state) -0.5f;
            // dla czytelnosci podmienic to z get_ray w przyszlosci
            vec3 viewPortPixelIndex = camParams.pixel00_loc + ((i + x) * camParams.pixel_delta_u) + ((j + y) * camParams.pixel_delta_v);
            vec3 ray_direction = viewPortPixelIndex - camParams.cameraCenter;
            ray r(camParams.cameraCenter, ray_direction);
            color += renderKernelFunctions::ray_color(r, d_world, &local_rand_state);
        }

        d_fb[pixel_index] = color / float(spp);

        rand_state[pixel_index] = local_rand_state;
    }

    __global__ void create_world(hittable** d_list, hittable** d_world)
    {
        if (threadIdx.x == 0 && blockIdx.x == 0)
        {
            lambertian* material_ground = new lambertian(vec3(0.8f, 0.8f, 0.0f));
            lambertian* material_center = new lambertian(vec3(0.1f, 0.2f, 0.5f));
            metal* material_left = new metal (vec3(0.8f, 0.8f, 0.8f));
            metal* material_right = new metal(vec3(0.8f, 0.6f, 0.2f));
            *(d_list) = new sphere(point3(0.0f, -100.5f, -1.0f), 100.0f, material_ground);
            *(d_list + 1) = new sphere(point3(0.0f, 0.0f, -1.2f), 0.5f, material_center);
            *(d_list + 2) = new sphere(point3(-1.0f, 0.0f, -1.0f), 0.5f, material_left);
            *(d_list + 3) = new sphere(point3(1.0f, 0.0f, -1.0f), 0.5f, material_right);
            *d_world = new hittable_list(d_list, 4);
        }
    }

    __global__ void clear_world(hittable** d_list, hittable** d_world)
    {
        if (threadIdx.x == 0 && blockIdx.x == 0)
        {
            // czy nie trzeba tu dwalniac pointerow do lambertian i metal????
            // TODO
            delete* (d_list);
            delete* (d_list + 1);
            delete* (d_list + 2);
            delete* (d_list + 3);
            delete* d_world;
        }
    }
}

void camera::Init()
{
    image_height = static_cast<int>(image_width / aspect_ratio);
    image_height = (image_height < 1) ? 1 : image_height;

    piexel_samples_scale = 1.0f / samples_per_pixel;

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

    blockSize = dim3(16, 16);
    gridSize = dim3((image_width + blockSize.x - 1) / blockSize.x, (image_height + blockSize.y - 1) / blockSize.y);
}
__device__ ray camera::get_ray(int index_i, int index_j, float offset_x, float offset_y) const
{
    // jak wyrzuce camera** d_camera z pola klasy camera i przeniose to gdzie indziej
    // i uda mi sie ogarnac stworzenie tej klasy camera na gpu, to wtedy uzyæ t¹ funkcje (this)
    // w kernelu render_framebuffer
    vec3 viewPortPixelIndex = pixel00_loc + ((index_i + offset_x) * pixel_delta_u) + ((index_j + offset_y) * pixel_delta_v);
    vec3 ray_direction = viewPortPixelIndex - cameraCenter;
    return ray(cameraCenter, ray_direction);
}

camera::camera()
{
    Init();
    GPU_variables::init(image_width, image_height, 4);
    GPU_variables& gpu_vars = GPU_variables::getInstance();
    render_params* h_render_params = gpu_vars.getRenderParams();

    renderKernelFunctions::create_world << <1, 1 >> > (h_render_params->d_list, h_render_params->d_world);
    checkCudaErrors(cudaGetLastError());
    checkCudaErrors(cudaDeviceSynchronize());
    renderKernelFunctions::init_rand_state << <gridSize, blockSize >> > (h_render_params->d_rand_state, image_width, image_height);
    checkCudaErrors(cudaGetLastError());
    checkCudaErrors(cudaDeviceSynchronize());
}

camera::~camera()
{
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
    camParams.samples_per_pixel = samples_per_pixel;

    std::vector<vec3> fb(image_width * image_height);

    GPU_variables& gpu_vars = GPU_variables::getInstance();
    render_params* h_render_params = gpu_vars.getRenderParams();
    // uzyc check_ptr_type w jakis madry sposob o tu
    vec3* d_fb = h_render_params->d_fb;
    hittable** d_world = h_render_params->d_world;
    curandState* d_rand_state = h_render_params->d_rand_state;

    renderKernelFunctions::render_framebuffer << <gridSize, blockSize >> > (d_fb, d_world, camParams, d_rand_state);
    checkCudaErrors(cudaGetLastError());
    checkCudaErrors(cudaDeviceSynchronize());
    checkCudaErrors(cudaMemcpy(fb.data(), d_fb, image_width * image_height * sizeof(vec3), cudaMemcpyDeviceToHost));
    std::cout << "P3\n" << image_width << " " << image_height << "\n255\n";
    for (int j = 0; j < image_height; j++) {
        for (int i = 0; i < image_width; i++) {
            size_t pixel_index = j * image_width + i;
            vec3 pixel_color = fb[pixel_index];
            write_color(std::cout, pixel_color);
        }
    }
}
