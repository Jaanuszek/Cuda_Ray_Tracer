#ifndef GENERAL_INCLUDES_CUH
#define GENERAL_INCLUDES_CUH

#include <cmath>
#include <iostream>
#include <limits>
#include <memory>

#include "cuda_runtime.h"

namespace constants {
	constexpr float infinity = std::numeric_limits<float>::infinity();
	constexpr float pi = 3.1415926535897932385f;
}
__host__ __device__ inline float degrees_to_radians(float degrees) {
	return degrees * constants::pi / 180.0f;
}

#include "vec3.cuh"
#include "ray.cuh"
#include "color.cuh"

#endif