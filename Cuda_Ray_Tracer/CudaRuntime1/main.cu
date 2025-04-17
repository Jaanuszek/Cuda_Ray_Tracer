
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <iostream>

int main()
{
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	int image_width = 256;
	int image_height = 256;

	cudaEventRecord(start);
	std::cout << "P3\n" << image_width << " " << image_height << "\n255\n";

	for (int j = 0; j < image_height; j++)
	{
		//std::clog << "\rScanlines remaining: " << (image_height - j) << " " << std::flush;
		for (int i = 0; i < image_width; i++)
		{
			auto r = float(i) / (image_width - 1);
			auto g = float(j) / (image_height - 1);
			auto b = 0.0;

			int ir = int(255.999 * r);
			int ig = int(255.999 * g);
			int ib = int(255.999 * b);

			//std::cout << ir << " " << ig << " " << ib << std::endl;
		}
	}
	std::clog << "\rDone.							\n";
	cudaEventRecord(stop);
	cudaEventSynchronize(stop);
	float milliseconds = 0;
	cudaEventElapsedTime(&milliseconds, start, stop);
	std::clog << "Elapsed time: " << milliseconds << std::endl;
}
