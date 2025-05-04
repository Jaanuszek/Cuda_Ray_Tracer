#ifndef CAMERA_CUH
#define CAMERA_CUH

#include <curand_kernel.h>
#include "general_includes.cuh"
#include "vec3.cuh"
#include "Color.cuh"
#include "ray.cuh"
#include "hittable.cuh"
#include "sphere.cuh"
#include "hittable_list.cuh"
#include "material.cuh"

struct camera_params {
    int image_width;
    int image_height;
    point3 cameraCenter;
    vec3 pixel00_loc;
    vec3 pixel_delta_u;
    vec3 pixel_delta_v;
    float samples_per_pixel;
};

class camera;

namespace renderKernelFunctions {
    __device__ color ray_color(const ray& r, hittable** world);
    __global__ void init_rand_state(curandState* rand_state, int width, int height);
    __global__ void render_framebuffer(vec3* d_fb, hittable** d_world, camera_params camParams, curandState* rand_state);
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
    float piexel_samples_scale;

    dim3 blockSize;
    dim3 gridSize;

    //// cuda variables
    //curandState *d_rand_state;
    //hittable **d_list;
    //hittable **d_world;
    //vec3 *d_fb;
    //camera** d_camera; //wywalic to

    void Init();
    __device__ ray get_ray(int index_i, int index_j, float offset_x, float offset_y) const;
public:
    float aspect_ratio = 16.0f / 9.0f;
    int image_width = 400;
    int samples_per_pixel = 100;
    __host__ __device__ camera();
    __host__ __device__ ~camera(); // TODO w destruktorze wywolac cudaFree i clear_world

    __host__ void render();
};

#endif