#ifndef SPHERE_CUH
#define SPHERE_CUH

#include "hittable.cuh"

class sphere : public hittable
{
private:
	point3 m_center;
	float m_radius;
public:
	sphere(const point3& center, float radius);
	bool hit(const ray& r, float ray_tmin, float ray_tmax, hit_record& rec) const override;
};

#endif