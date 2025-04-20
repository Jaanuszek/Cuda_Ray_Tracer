#ifndef HITTABLE_CUH
#define HITTABLE_CUH

#include "ray.cuh"

class hit_record
{
public:
	point3 p; // hit point
	vec3 normal; // normal at hit point
	float t;
	bool front_face;

	void set_face_normal(const ray& r, const vec3& outward_normal)
	{
		front_face = dot(r.get_direction(), outward_normal) < 0.0f;
		normal = front_face ? outward_normal : -outward_normal;
	}
};

class hittable
{
public:
	virtual ~hittable() = default;
	virtual bool hit(const ray& r, float ray_tmin, float ray_tmax, hit_record& rec) const = 0;
};

#endif // !HITTABLE_CUH
