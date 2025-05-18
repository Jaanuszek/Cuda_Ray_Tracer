#ifndef GPU_FACTORY_CUH
#define GPU_FACTORY_CUH

#include <vector>
#include "material.cuh"
#include "lambertian.cuh"
#include "metal.cuh"
#include "dielectric.cuh"
#include "sphere.cuh"
#include "box.cuh"
#include "cylinder.cuh"

enum class ObjectType
{
    Sphere,
    Cube,
    Cone,
    Cylinder
};

enum class MaterialType
{
    Lambertian,
    Metal,
    Dielectric
};

struct GenericType
{
    ObjectType obj_type;
    void* object_ptr;
    MaterialType mat_type;
    void* mat_ptr;
};

class sphere;
class box;
class cylinder;

class GPU_factory
{
private:
    std::vector<void*> GPU_allocations;
public:
    ~GPU_factory();

    template<typename T>
    T* uploadToGPU(const T& obj)
    {
        T* device_ptr = nullptr;
        checkCudaErrors(cudaMalloc((void**)&device_ptr, sizeof(T)));
        checkCudaErrors(cudaMemcpy(device_ptr, &obj, sizeof(T), cudaMemcpyHostToDevice));
        GPU_allocations.push_back(device_ptr);
        return device_ptr;
    }

    template<typename T>
    T* uploadArrayToGPU(const T* host_array, size_t count)
    {
        T* device_ptr = nullptr;
        checkCudaErrors(cudaMalloc((void**)&device_ptr, sizeof(T) * count));
        checkCudaErrors(cudaMemcpy(device_ptr, host_array, sizeof(T) * count, cudaMemcpyHostToDevice));
        GPU_allocations.push_back(device_ptr);
        return device_ptr;
    }

    void* createLambertian(const vec3& albedo);
    void* createMetal(const vec3& albedo, float fuzz);
    void* createDielectric(float reflectation_index);

    sphere* createSphere(const vec3& center, float radius);
    box* createBox(const vec3& min, const vec3& max);
    cylinder* createCylinder(const vec3& center, float radius, float height);
};

#endif