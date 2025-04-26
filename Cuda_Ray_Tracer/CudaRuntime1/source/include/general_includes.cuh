#ifndef GENERAL_INCLUDES_CUH
#define GENERAL_INCLUDES_CUH

#include <cmath>
#include <iostream>
#include <limits>
#include <memory>
#include <random>

#include "cuda_runtime.h"

#define checkCudaErrors(val) check_cuda( (val), #val, __FILE__, __LINE__)

inline void check_cuda(cudaError_t result, const char* func, const char* file, const int line)
{
	// spróbowac kiedys tutaj dodaæ rzucanie wyj¹tku a nie exit, ale to tak dla sportu
	if (result != cudaSuccess) {
		std::cerr << "CUDA error (" << static_cast<unsigned int>(result) << "): "
			<< cudaGetErrorString(result)
			<< " at " << file << ":" << line
			<< " in call to '" << func << "'\n";
		cudaDeviceReset();
		exit(EXIT_FAILURE);
	}
}

namespace constants {
	constexpr float infinity = std::numeric_limits<float>::infinity();
	constexpr float pi = 3.1415926535897932385f;
}
__host__ __device__ inline float degrees_to_radians(float degrees) {
	return degrees * constants::pi / 180.0f;
}

__host__ __device__ inline float random_float()
{
    std::uniform_real_distribution<float> distribution(0.0f, 1.0f);
    std::mt19937 generator;
    return distribution(generator);
}

__host__ __device__ inline float random_float(float min, float max)
{
    return min + (max - min) * random_float();
}

//#include "vec3.cuh"
//#include "ray.cuh"
//#include "interval.cuh"

#endif