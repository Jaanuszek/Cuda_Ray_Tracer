#ifndef HITTABLE_CUH
#define HITTABLE_CUH


#include "general_includes.cuh"

class hit_record
{
public:
	point3 p; // hit point
	vec3 normal; // normal at hit point
	float t;
	bool front_face;

	__host__ __device__ void set_face_normal(const ray& r, const vec3& outward_normal)
	{
		front_face = dot(r.get_direction(), outward_normal) < 0.0f;
		normal = front_face ? outward_normal : -outward_normal;
	}
};

class hittable
{
public:
	//__host__ __device__ virtual ~hittable() = default;
	__device__ ~hittable() {}
	__host__ __device__ virtual bool hit(const ray& r, float ray_tmin, float ray_tmax, hit_record& rec) const = 0;
};

#endif // !HITTABLE_CUH
