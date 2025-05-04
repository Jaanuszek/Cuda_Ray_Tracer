#ifndef MATERIAL_CUH
#define MATERIAL_CUH

#include "hittable.cuh"
#include "ray.cuh"

class material {
public:
	__device__ virtual bool scatter(
		const ray& r_in, const hit_record& rec,
		vec3& attenuation, ray& scattered,
		curandState* r_state
		) const = 0;
};

#endif