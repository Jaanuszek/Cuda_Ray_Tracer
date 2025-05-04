#ifndef METAL_CUH
#define METAL_CUH

#include "material.cuh"

class metal : public material {
private:
	vec3 albedo;
	float fuzz;
public:
	__device__ metal(const vec3& albedo, float fuzz) : albedo(albedo), fuzz(fuzz < 1 ? fuzz : 1) {}
	__device__ bool scatter(
		const ray& r_in, const hit_record& rec,
		vec3& attenuation, ray& scattered,
		curandState* r_state
	) const override
	{
		vec3 reflected = reflect(r_in.get_direction(), rec.normal);
        reflected = unit_vector(reflected) + (fuzz * random_unit_vec(r_state));
		scattered = ray(rec.p, reflected);
		attenuation = albedo;
		return (dot(scattered.get_direction(), rec.normal) > 0);
	}
};

#endif