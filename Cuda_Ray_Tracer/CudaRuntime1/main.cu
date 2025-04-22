
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include "source/include/general_includes.cuh"
#include <vector>
#include "source/include/hittable.cuh"
#include "source/include/hittable_list.cuh"
#include "source/include/sphere.cuh"

#define checkCudaErrors(val) check_cuda( (val), #val, __FILE__, __LINE__)

inline void check_cuda(cudaError_t result, const char* func, const char* file, const int line)
{
	// spróbowac kiedys tutaj dodać rzucanie wyjątku a nie exit, ale to tak dla sportu
	if (result != cudaSuccess) {
		std::cerr << "CUDA error (" << static_cast<unsigned int>(result) << "): "
			<< cudaGetErrorString(result)
			<< " at " << file << ":" << line
			<< " in call to '" << func << "'\n";
		cudaDeviceReset();
		exit(EXIT_FAILURE);
	}
}

__device__ unsigned char float_to_unchar(float c)
{
	return static_cast<unsigned char>(255.999f * fminf(fmaxf(c, 0.0f), 1.0f));
}

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

__global__ void render_framebuffer(vec3* d_fb, int image_width, int image_height, vec3 pixel00_loc,
	vec3 deltaU, vec3 deltaV, vec3 origin, hittable** d_world)
{
	int i = threadIdx.x + blockDim.x * blockIdx.x; // width
	int j = threadIdx.y + blockDim.y * blockIdx.y; //height

	if (i >= image_width || j >= image_height) return;

	int pixel_index = j * image_width + i;
	auto viewPortPixelIndex = pixel00_loc + (i * deltaU) + (j * deltaV);
	auto ray_direction = viewPortPixelIndex - origin;
	ray r(origin, ray_direction);
	d_fb[pixel_index] = ray_color(r, d_world);
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

int main()
{
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	float milliseconds = 0;

	float aspect_ratio = 16.0f / 9.0f;
	int image_width = 400;
	int image_height = static_cast<int>(image_width / aspect_ratio);
	image_height = (image_height < 1) ? 1 : image_height;

	int num_pixel = image_width * image_height;
	size_t pixelsSizeInBytes = num_pixel * sizeof(vec3);

	// Viewport size
	float viewport_height = 2.0f;
	float viewport_width = viewport_height * (float(image_width) / image_height);

	float focal_length = 1.0f; // distance from camera to viewport
	point3 cameraCenter(0, 0, 0); // camera position
	vec3 viewport_u(viewport_width, 0, 0); // viewport width
	vec3 viewport_v(0, -viewport_height, 0); // viewport height - because we are going from up left to bottom right

	vec3 pixel_delta_u = viewport_u / image_width;
	vec3 pixel_delta_v = viewport_v / image_height;

	auto viewport_upper_left = cameraCenter - vec3(0,0, focal_length) - (viewport_u / 2) - (viewport_v / 2);
	auto pixel00_loc = viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v);

	// on GPU
	hittable** d_list;
	size_t listSizeInBytes = sizeof(hittable*) * 2;
	checkCudaErrors(cudaMalloc(&d_list, listSizeInBytes));
	hittable** d_world;
	checkCudaErrors(cudaMalloc(&d_world, sizeof(hittable*)));

	create_world <<<1, 1 >>> (d_list, d_world);
	checkCudaErrors(cudaGetLastError());
	checkCudaErrors(cudaDeviceSynchronize());

	std::cout << "P3\n" << image_width << " " << image_height << "\n255\n";
	std::vector<vec3> fb(num_pixel);
	vec3* d_fb;
	checkCudaErrors(cudaMalloc(&d_fb, pixelsSizeInBytes));
	dim3 threadsPerBlock(16, 16);
	dim3 numBlocks((image_width + threadsPerBlock.x - 1) / threadsPerBlock.x,
		(image_height + threadsPerBlock.y - 1) / threadsPerBlock.y);
	cudaEventRecord(start);
	render_framebuffer << <numBlocks, threadsPerBlock >> > (d_fb, image_width, image_height, pixel00_loc,
		pixel_delta_u, pixel_delta_v, cameraCenter, d_world);
	checkCudaErrors(cudaGetLastError());
	checkCudaErrors(cudaDeviceSynchronize());
	checkCudaErrors(cudaMemcpy(fb.data(), d_fb, pixelsSizeInBytes, cudaMemcpyDeviceToHost));
	cudaEventRecord(stop);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&milliseconds, start, stop);
	std::clog << "Elapsed time(GPU): " << milliseconds << std::endl;
	for (int j = 0; j < image_height; j++) {
		for (int i = 0; i < image_width; i++) {
			size_t pixel_index = j * image_width + i;
			auto pixel_color = fb[pixel_index];
			write_color(std::cout, pixel_color);
		}
	}

	clear_world << <1, 1 >> > (d_list, d_world);
	checkCudaErrors(cudaGetLastError());
	checkCudaErrors(cudaDeviceSynchronize());

	checkCudaErrors(cudaFree(d_list));
	checkCudaErrors(cudaFree(d_world));
	checkCudaErrors(cudaFree(d_fb));
}
