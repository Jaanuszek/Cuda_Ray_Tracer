#ifndef CAMERA_CUH
#define CAMERA_CUH

#include "general_includes.cuh"
#include "hittable.cuh"
#include "sphere.cuh"
#include "hittable.cuh"
#include "hittable_list.cuh"

struct camera_params {
    int image_width;
    int image_height;
    point3 cameraCenter;
    vec3 pixel00_loc;
    vec3 pixel_delta_u;
    vec3 pixel_delta_v;
};

namespace renderKernelFunctions {
    __device__ color ray_color(const ray& r, hittable** world);
    __global__ void render_framebuffer(vec3* d_fb, hittable** d_world, camera_params camParams);
    __global__ void create_world(hittable** d_list, hittable** d_world);
    __global__ void clear_world(hittable** d_list, hittable** d_world);
}

class camera {
private:
    int image_height;
    point3 cameraCenter;
    point3 pixel00_loc;
    vec3 pixel_delta_u;
    vec3 pixel_delta_v;

    // cuda variables
    hittable** d_list;
    hittable** d_world;
    vec3* d_fb;

    void Init();
public:
    camera();
    ~camera(); // TODO w destruktorze wywolac cudaFree i clear_world
    float aspect_ratio = 16.0f / 9.0f;
    int image_width = 400;

    __host__ void render();
};

#endif