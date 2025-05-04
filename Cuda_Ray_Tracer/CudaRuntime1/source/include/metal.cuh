#ifndef METAL_CUH
#define METAL_CUH

#include "material.cuh"

class metal : public material {
private:
	vec3 albedo;
public:
	__device__ metal(const vec3& albedo) : albedo(albedo) {}
	__device__ bool scatter(
		const ray& r_in, const hit_record& rec,
		vec3& attenuation, ray& scattered,
		curandState* r_state
	) const override
	{
		vec3 reflected = reflect(r_in.get_direction(), rec.normal);
		scattered = ray(rec.p, reflected);
		attenuation = albedo;
		return true;
	}
};

#endif