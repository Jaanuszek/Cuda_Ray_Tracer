#ifndef DIELECTRIC_CUH
#define DIELECTRIC_CUH

#include "material.cuh"

class dielectric : public material {
private:
    float ref_idx;

    // r0 to odbicie przy k¹cie prostym "normal incidence"
    __device__ static float reflectance(float cos, float refraction_index)
    {
        float r0 = (1 - refraction_index) / (1 + refraction_index);
        r0 = r0 * r0;
        return r0 + (1 - r0) * powf((1 - cos), 5);
    }
public:
    __device__ dielectric(float ri) : ref_idx(ri) {}
    __device__ bool scatter(const ray& r_in, const hit_record& rec, vec3& attenuation, ray& scattered, curandState* r_state)
        const override {
        attenuation = vec3(1.0f, 1.0f, 1.0f);
        // jezeli trafiamy w zewnêtrzn¹ powierzhcnie, to promien przechodzi z powietrza do szk³a 1.0/ref_idx
        // jezeli w wewnêtrzn¹, to promien przechodzi ze szk³a do powietrza ref_idx
        float ri = rec.front_face ? (1.0f / ref_idx) : ref_idx;

        vec3 unit_direction = unit_vector(r_in.get_direction());

        float cos_theta = fmin(dot(-unit_direction, rec.normal), 1.0f);
        float sin_theta = sqrt(1.0f - cos_theta * cos_theta);

        bool cannot_refract = ri * sin_theta > 1.0f;

        vec3 direction;

        if (cannot_refract || reflectance(cos_theta, ri) > curand_uniform(r_state))
        {
            direction = reflect(unit_direction, rec.normal);
        }
        else
        {
            direction = refract(unit_direction, rec.normal, ri);
        }

        scattered = ray(rec.p, direction);
        return true;
    }
};

#endif