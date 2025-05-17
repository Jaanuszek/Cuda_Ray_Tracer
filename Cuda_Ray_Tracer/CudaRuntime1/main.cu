
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

__global__ void debug(GenericType* objs) {
    GenericType* obj = &objs[0];
    printf("obj->mat_ptr = %p\n", obj->mat_ptr);
    printf("obj->object_ptr = %p\n", obj->object_ptr);
}

int main()
{
    std::vector<GenericType> GPU_scene;
    GPU_factory gpu_factory;
    void *d_mat_ptr = gpu_factory.createLambertian(vec3(0.3f, 0.3f, 1.0f));
    GPU_scene.push_back(
        { ObjectType::Sphere,
            (void*)gpu_factory.createSphere(vec3(0.0f, 0.0f, 0.0f), 0.5f),
            MaterialType::Lambertian,
            d_mat_ptr
        }
    );
    void* d_mat_ptr2 = gpu_factory.createMetal(vec3(0.1f, 0.8f, 0.5f), 0.0f);
    GPU_scene.push_back(
        {
            ObjectType::Sphere,
            (void*)gpu_factory.createSphere(vec3(1.0f, 0.0f, -1.0f), 0.5f),
            MaterialType::Metal,
            d_mat_ptr2
        }
    );

    size_t sceneSize = GPU_scene.size();
    GenericType* d_obj = gpu_factory.uploadArrayToGPU(GPU_scene.data(), sceneSize);

    GPU_world h_scene(d_obj, sceneSize);

    GPU_world* d_scene = gpu_factory.uploadToGPU(h_scene);

    //debug << <1,1 >> > (d_obj);
    //checkCudaErrors(cudaGetLastError());
    //checkCudaErrors(cudaDeviceSynchronize());



    //GPU_variables::init(400, 300, 2);
    //GPU_variables& gpu_vars = GPU_variables::getInstance();
    //render_params* h_render_params = gpu_vars.getRenderParams();
    camera cam(d_scene);
    cam.render();
}