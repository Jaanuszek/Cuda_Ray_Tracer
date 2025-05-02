#ifndef SPHERE_CUH
#define SPHERE_CUH


#include "general_includes.cuh"
#include "hittable.cuh"
#include "vec3.cuh"
#include "ray.cuh"

class sphere : public hittable
{
private:
	point3 m_center;
	float m_radius;
public:
	__device__ sphere() {}
	__device__ sphere(const point3& center, float radius);
	__device__ bool hit(const ray& r, interval ray_t, hit_record& rec) const override;
};

#endif