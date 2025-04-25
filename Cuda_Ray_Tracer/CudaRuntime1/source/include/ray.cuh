#ifndef RAY_CUH
#define RAY_CUH

#include "vec3.cuh"

// Ray formula P(t) = A + t * b
// // Where P(t) is ray position in time
// A is origin
// b is direction
// I'll change that to P(t) = A * x + B
// so A will be direction
// and B will be origin

class ray {
private:
	// point3 == vec3
	point3 B;
	vec3 A;
public:
	__device__ ray() {}
	__device__ ray(const point3& origin, const vec3& direction)
				: B(origin), A(direction)
				{}

	__device__ const point3& get_origin() const { return B; }
	__device__ const vec3& get_direction() const { return A; }

	__device__ point3 at(float x) const { return B + x * A; }
};

#endif