
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <iostream>

#define checkCudaErrors(val) check_cuda( (val), #val, __FILE__, __LINE__)

void check_cuda(cudaError_t result, const char* func, const char* file, const int line)
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

__global__ void createPPM(float *d_fb, int image_width, int image_height)
{
	int i = threadIdx.x + blockDim.x * blockIdx.x; // width
	int j = threadIdx.y + blockDim.y * blockIdx.y; //height

	if (i >= image_width || j >= image_height) return;

	int pixel_index = j * image_width + i;

	float r = float(i) / (image_width - 1);
	float g = float(j) / (image_height - 1);
	float b = 0.0f;

	d_fb[pixel_index * 3] = r;
	d_fb[pixel_index * 3 + 1] = g;
	d_fb[pixel_index * 3 + 2] = b;
}

int main()
{
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	float milliseconds = 0;
	int image_width = 256;
	int image_height = 256;
	int num_pixel = image_width * image_height;
	size_t pixelsSizeInBytes = num_pixel * 3* sizeof(float);

	float* fb = new float[num_pixel * 3]; //*3 becasue (R, G, B) (float, float, float)
	float* d_fb;
	checkCudaErrors(cudaMalloc(&d_fb, pixelsSizeInBytes));
	dim3 threadsPerBlock(16, 16);
	dim3 numBlocks((image_width + threadsPerBlock.x - 1) / threadsPerBlock.x,
		(image_height + threadsPerBlock.y - 1) / threadsPerBlock.y);
	cudaEventRecord(start);
	createPPM << <numBlocks, threadsPerBlock >> > (d_fb, image_width, image_height);
	checkCudaErrors(cudaGetLastError());
	checkCudaErrors(cudaMemcpy(fb, d_fb, pixelsSizeInBytes, cudaMemcpyDeviceToHost));
	//std::cout << "P3\n" << image_width << " " << image_height << "\n255\n";
	for (int j = 0; j < image_height; j++)
	{
		for (int i = 0; i < image_width; i++)
		{
			int pixel_index = j * image_width + i;
			int ir = int(255.999 * fb[pixel_index * 3]);
			int ig = int(255.999 * fb[pixel_index * 3 + 1]);
			int ib = int(255.999 * fb[pixel_index * 3 + 2]);
			//std::cout << ir << " " << ig << " " << ib << std::endl;
		}
	}
	cudaEventRecord(stop);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&milliseconds, start, stop);
	std::cout << "Elapsed time(GPU): " << milliseconds << std::endl;
	cudaFree(d_fb);
	delete[] fb;
}
