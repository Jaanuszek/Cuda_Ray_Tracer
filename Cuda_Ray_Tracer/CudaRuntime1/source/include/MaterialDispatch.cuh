#ifndef MATERIALDISPATCH_CUH
#define MATERIALDISPATCH_CUH

#include "hittable.cuh"
#include "lambertian.cuh"
#include "metal.cuh"
#include "dielectric.cuh"
#include "GPU_factory.cuh"

__device__ bool choseScatter(MaterialType mat_type, void* mat_ptr, const ray& r_in, const hit_record& rec, vec3& attenuation, ray& scattered,
    curandState* r_state)
{
    switch (mat_type)
    {
    case (MaterialType::Lambertian):
        return ((lambertian*)mat_ptr)->scatter(r_in, rec, attenuation, scattered, r_state);
    case (MaterialType::Metal):
        return ((metal*)mat_ptr)->scatter(r_in, rec, attenuation, scattered, r_state);
    case (MaterialType::Dielectric):
        return ((dielectric*)mat_ptr)->scatter(r_in, rec, attenuation, scattered, r_state);

    default:
        return false;
    }
}

#endif