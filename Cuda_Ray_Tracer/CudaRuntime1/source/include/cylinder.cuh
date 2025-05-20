#ifndef CYLINDER_CUH
#define CYLINDER_CUH

#include "general_includes.cuh"
#include "hittable.cuh"
#include "vec3.cuh"
#include "ray.cuh"
#include "GPU_factory.cuh"
#include <math.h>

class cylinder
{
public:
    const vec3 center;
    float radius;
    float height;
    cylinder(const vec3& center, float radius, float height) : center(center), radius(radius), height(height){}
    __device__ bool hit(const ray& r, interval ray_t, hit_record& rec, void* mat, MaterialType mat_type);
};

#endif