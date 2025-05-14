
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <curand_kernel.h>

#include <stdio.h>
#include "source/include/general_includes.cuh"
#include <vector>
#include "source/include/hittable.cuh"
#include "source/include/hittable_list.cuh"
#include "source/include/sphere.cuh"
#include "source/include/camera.cuh"
#include "source/include/GPU_variables.cuh"
#include "source/include/lambertian.cuh"
#include "source/include/metal.cuh"

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

struct WorldObjects
{
    GenericType* objects;
    int objectsCount;
};

__global__ void checkNewMemoryStructure(GenericType* objects, size_t objectsCount)
{
    for (int i = 0; i < objectsCount; i++) {
        GenericType *obj = &objects[i];
        switch (obj->mat_type)
        {
        case(MaterialType::Lambertian):
            if (((lambertian*)obj->mat_ptr) != NULL)
            {
                printf("git\n");
                ((lambertian*)obj->mat_ptr)->tempFunc();
            }
            break;
        case(MaterialType::Metal):
            if (((metal*)obj->mat_ptr) != NULL)
            {
                printf("git ale metal\n");
                ((metal*)obj->mat_ptr)->tempFunc();
            }
            break;
        default:
            printf("gowno\n");
            break;
        }

        switch (obj->obj_type)
        {
        case(ObjectType::Sphere):
            if (((sphere*)obj->object_ptr) != NULL)
            {
                printf("Git obj\n");
                ((sphere*)obj->object_ptr)->tempFunc();
            }
            break;
        default:
            printf("nooooo\n");
            break;
        }
    }
}

int main()
{
    std::vector<void*> gpu_allocations;
    std::vector<GenericType> GPU_scene;

    material* h_mat_ptr = new lambertian(vec3(0.5f, 0.5f, 0.5f));
    material* d_mat_ptr;
    checkCudaErrors(cudaMalloc((void**)&d_mat_ptr, sizeof(lambertian)));
    checkCudaErrors(cudaMemcpy(d_mat_ptr, h_mat_ptr, sizeof(lambertian), cudaMemcpyHostToDevice));
    gpu_allocations.push_back(d_mat_ptr);
    material* h_mat_ptr2 = new metal(vec3(0.5f, 0.5f, 0.5f), 0.0f);
    material* d_mat_ptr2;
    checkCudaErrors(cudaMalloc((void**)&d_mat_ptr2, sizeof(metal)));
    checkCudaErrors(cudaMemcpy(d_mat_ptr2, h_mat_ptr2, sizeof(metal), cudaMemcpyHostToDevice));
    gpu_allocations.push_back(d_mat_ptr2);

    sphere* h_sp1 = new sphere(vec3(0.0f, 0.0f, 0.0f), 0.5f, h_mat_ptr);
    h_sp1->mat_ptr = d_mat_ptr;
    sphere* d_sp1;
    checkCudaErrors(cudaMalloc((void**)&d_sp1, sizeof(sphere)));
    checkCudaErrors(cudaMemcpy(d_sp1, h_sp1, sizeof(sphere), cudaMemcpyHostToDevice));
    gpu_allocations.push_back(d_sp1);

    sphere* h_sp2 = new sphere(vec3(0.2f, 0.0f, -1.0f), -0.5f, h_mat_ptr2);
    h_sp2->mat_ptr = d_mat_ptr2;
    sphere* d_sp2;
    checkCudaErrors(cudaMalloc((void**)&d_sp2, sizeof(sphere)));
    checkCudaErrors(cudaMemcpy(d_sp2, h_sp2, sizeof(sphere), cudaMemcpyHostToDevice));
    gpu_allocations.push_back(d_sp2);

    GPU_scene.push_back({ ObjectType::Sphere, (void*)d_sp1, MaterialType::Lambertian, (void*)d_mat_ptr });
    GPU_scene.push_back({ ObjectType::Sphere, (void*)d_sp2, MaterialType::Metal, (void*)d_mat_ptr2 });

    GenericType* d_obj;

    checkCudaErrors(cudaMalloc((void**)&d_obj, GPU_scene.size() * sizeof(GenericType)));
    checkCudaErrors(cudaMemcpy(d_obj, GPU_scene.data(), GPU_scene.size() * sizeof(GenericType), cudaMemcpyHostToDevice));
    gpu_allocations.push_back(d_obj);

    size_t sceneSize = GPU_scene.size();
    checkNewMemoryStructure << <1,1 >> > (d_obj, sceneSize);
    checkCudaErrors(cudaGetLastError());
    checkCudaErrors(cudaDeviceSynchronize());

    for (void* ptr : gpu_allocations)
    {
        checkCudaErrors(cudaFree(ptr));
    }
    delete h_mat_ptr;
    delete h_mat_ptr2;
    delete h_sp1;
    delete h_sp2;

    //GPU_variables::init(400, 300, 2);
    //GPU_variables& gpu_vars = GPU_variables::getInstance();
    //render_params* h_render_params = gpu_vars.getRenderParams();
    //camera cam;
    //cam.render();
}