#include "include/GPU_factory.cuh"

GPU_factory::~GPU_factory()
{
    //std::cout << "Destructor GPU_factory\n";
    for (auto ptr : GPU_allocations)
    {
        checkCudaErrors(cudaFree(ptr));
    }
}

void* GPU_factory::createLambertian(const vec3& albedo)
{
    lambertian* host_mat_ptr = new lambertian(albedo);
    lambertian* device_mat_ptr = uploadToGPU(*host_mat_ptr);
    delete host_mat_ptr;
    return (void*)device_mat_ptr;
}

void* GPU_factory::createMetal(const vec3& albedo, float fuzz)
{
    metal* host_mat_ptr = new metal(albedo, fuzz);
    metal* device_mat_ptr = uploadToGPU(*host_mat_ptr);
    delete host_mat_ptr;
    return (void*)device_mat_ptr;
}

void* GPU_factory::createDielectric(float reflectation_index)
{
    dielectric* host_mat_ptr = new dielectric(reflectation_index);
    dielectric* device_mat_ptr = uploadToGPU(*host_mat_ptr);
    delete host_mat_ptr;
    return (void*)device_mat_ptr;
}

sphere* GPU_factory::createSphere(const vec3 & center, float radius)
{
    sphere host_sphere = sphere(center, radius);
    sphere* device_sphere_ptr = uploadToGPU(host_sphere);
    return device_sphere_ptr;
}