#ifndef SPHERE_CUH
#define SPHERE_CUH


#include "general_includes.cuh"
#include "hittable.cuh"

class sphere : public hittable
{
private:
	point3 m_center;
	float m_radius;
public:
	__host__ __device__ sphere() {}
	__host__ __device__ sphere(const point3& center, float radius);
	__host__ __device__ bool hit(const ray& r, float ray_tmin, float ray_tmax, hit_record& rec) const override;
};

#endif