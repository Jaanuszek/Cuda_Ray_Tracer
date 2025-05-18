#ifndef BOX_CUH
#define BOX_CUH

#include "general_includes.cuh"
#include "hittable.cuh"
#include "vec3.cuh"
#include "ray.cuh"
#include "GPU_factory.cuh"

//AABB - axis-aligned bounding box, czyli ze dpasowujemy obiekt do ukladu wspolrzednych a nie uklad wspolrzednych do obiektu
class box
{
private:
    __device__ vec3 calculateNormals(const vec3& p);
public:
    vec3 bounds[2];
    __host__ __device__ box(const vec3& vmin, const vec3& vmax)
    {
        bounds[0] = vec3(
            fminf(vmin.x(), vmax.x()),
            fminf(vmin.y(), vmax.y()),
            fminf(vmin.z(), vmax.z())
        );
        bounds[1] = vec3(
            fmaxf(vmin.x(), vmax.x()),
            fmaxf(vmin.y(), vmax.y()),
            fmaxf(vmin.z(), vmax.z())
        );
    }

    __device__ bool hit(const ray& r, interval ray_t, hit_record& rec, void* mat, MaterialType mat_type);
};

#endif