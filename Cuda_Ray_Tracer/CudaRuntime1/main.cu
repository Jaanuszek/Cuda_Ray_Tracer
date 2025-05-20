
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
#include "source/include/GPU_factory.cuh"
#include "source/include/GPU_world.cuh"
#include "source/include/json.hpp"

int main()
{
    nlohmann::json j;
    std::vector<GenericType> GPU_scene;
    GPU_factory gpu_factory;

    void *d_mat_ptr = gpu_factory.createLambertian(vec3(0.5f, 0.5f, 0.5f));
    GPU_scene.push_back(
        { ObjectType::Sphere,
            (void*)gpu_factory.createSphere(point3(0.0f, -1000.0f, 0.0f), 1000.0f),
            MaterialType::Lambertian,
            d_mat_ptr
        }
    );
    void* d_mat_ptr2 = gpu_factory.createLambertian(vec3(0.1f, 0.2f, 0.5f));
    GPU_scene.push_back(
        {
            ObjectType::Sphere,
            (void*)gpu_factory.createSphere(point3(0.0f, 0.5f, -1.2f), 0.5f),
            MaterialType::Lambertian,
            d_mat_ptr2
        }
    );
    void* d_mat_ptr4 = gpu_factory.createDielectric(1.50f);
    GPU_scene.push_back(
        {
            ObjectType::Sphere,
            (void*)gpu_factory.createSphere(point3(-1.0f, 0.5f, -1.0f), 0.5f),
            MaterialType::Dielectric,
            d_mat_ptr4
        }
    );
    void* d_mat_ptr5 = gpu_factory.createDielectric(1.00f / 1.50f);
    GPU_scene.push_back(
        {
            ObjectType::Sphere,
            (void*)gpu_factory.createSphere(point3(-1.0f, 0.4f, -1.0f), 0.4f),
            MaterialType::Dielectric,
            d_mat_ptr5
        }
    );
    void* d_mat_ptr6 = gpu_factory.createMetal(vec3(0.8f, 0.6f, 0.2f), 0.0f);
    GPU_scene.push_back(
        {
            ObjectType::Sphere,
            (void*)gpu_factory.createSphere(point3(1.0f, 0.5f, -1.0f), 0.5f),
            MaterialType::Metal,
            d_mat_ptr6
        }
    );
    void* d_mat_ptr7 = gpu_factory.createMetal(vec3(0.8f, 0.6f, 0.2f), 0.0f);
    GPU_scene.push_back(
        {
            ObjectType::Cube,
            (void*)gpu_factory.createBox(vec3(2.0f, 0.5f, 0.0f), vec3(3.0f, 1.5f, -1.0f)),
            MaterialType::Metal,
            d_mat_ptr7
        }
    ); 
    void* d_mat_ptr8 = gpu_factory.createLambertian(vec3(0.7f, 0.3f, 0.3f));
    GPU_scene.push_back(
        {
            ObjectType::Cube,
            (void*)gpu_factory.createBox(vec3(-3.0f, 0.5f, 0.0f), vec3(-2.0f, 1.5f, -1.0f)),
            MaterialType::Lambertian,
            d_mat_ptr8
        }
    );
    void* d_mat_ptr9 = gpu_factory.createMetal(vec3(0.7f, 0.3f, 0.3f), 0.2f);
    GPU_scene.push_back(
        {
            ObjectType::Cylinder,
            (void*)gpu_factory.createCylinder(vec3(0.0f, 1.0f, -3.2f), 1.0f, 2.0f),
            MaterialType::Metal,
            d_mat_ptr9
        }
    );
    void* d_mat_ptr10 = gpu_factory.createMetal(vec3(1.0f, 0.0f, 0.0f), 0.0f);
    GPU_scene.push_back(
        {
            ObjectType::Cone,
            (void*)gpu_factory.createCone(vec3(2.0f, 0.5f, -1.5f), 0.5f, 1.5f),
            MaterialType::Metal,
            d_mat_ptr10
        }
    );

    size_t sceneSize = GPU_scene.size();
    GenericType* d_obj = gpu_factory.uploadArrayToGPU(GPU_scene.data(), sceneSize);

    GPU_world h_scene(d_obj, sceneSize);
    GPU_world* d_scene = gpu_factory.uploadToGPU(h_scene);

    camera cam(d_scene);
    cam.render();
}