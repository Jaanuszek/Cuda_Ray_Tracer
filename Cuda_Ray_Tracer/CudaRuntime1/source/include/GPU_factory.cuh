#ifndef GPU_FACTORY_CUH
#define GPU_FACTORY_CUH

#include <vector>
#include "material.cuh";
#include "lambertian.cuh";
#include "metal.cuh";
#include "dielectric.cuh";
#include "sphere.cuh";

class GPU_factory
{
private:
    std::vector<void*> gpu_allocations;
public:
    ~GPU_factory();

    material* createLambertian(const vec3& albedo);
    material* createMetal(const vec3& albedo, float fuzz);
    material* createDielectric(float reflectation_index);

    sphere* createSphere(const vec3& center, float radius, material* mat_ptr);
};

#endif