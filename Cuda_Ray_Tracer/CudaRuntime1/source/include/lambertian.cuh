#ifndef LAMBERTIAN_CUH
#define LAMBERTIAN_CUH

#include "material.cuh"

// Diffuse
class lambertian : public material {
private:
	vec3 albedo; // "Whiteness"
public:
	__device__ lambertian(const vec3& albedo) : albedo(albedo) {}
	__device__ bool scatter(
		const ray& r_in, const hit_record& rec, 
		vec3& attenuation, ray& scattered,
		curandState* r_state
	) const override
	{
		vec3 scatter_direction = rec.normal + random_unit_vec(r_state);
		if (scatter_direction.near_zero())
		{
			scatter_direction = rec.normal;
		}
		scattered = ray(rec.p, scatter_direction);
		attenuation = albedo;
		return true;
	}
};

#endif