#ifndef RAY_CUH
#define RAY_CUH

#include "vec3.cuh"

// Ray formula P(t) = A + t * b
// Where P(t) is ray position in time
// A is origin
// b is direction

class ray {
private:
	// point3 == vec3
	point3 m_origin;
	vec3 m_direction;
public:
	__host__ __device__ ray() {}
	__host__ __device__ ray(const point3& origin, const vec3& direction)
				: m_origin(origin), m_direction(direction)
				{}

	__host__ __device__ const point3& get_origin() const { return m_origin; }
	__host__ __device__ const vec3& get_direction() const { return m_direction; }

	__host__ __device__ point3 at(float t) const { return m_origin + t * m_direction; }
};

#endif