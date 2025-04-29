#ifndef GPU_BARIABLES_CUH
#define GPU_BARIABLES_CUH

#include <curand_kernel.h>
#include "general_includes.cuh"
#include "hittable.cuh"
#include "hittable_list.cuh"
#include "sphere.cuh"
#include "camera.cuh"

struct render_params
{
    curandState* d_rand_state;
    hittable** d_list;
    hittable** d_world;
    vec3* d_fb;
    camera** d_camera;
};

class GPU_variables
{
private:
    int image_width;
    int image_height;
    render_params* d_render_params;
    static GPU_variables* instance;
    __host__ GPU_variables();
    __host__ ~GPU_variables();
public:
    __host__ GPU_variables(const GPU_variables&) = delete;
    __host__ GPU_variables& operator=(const GPU_variables&) = delete;
    __host__ static void init();
    __host__ static GPU_variables& getInstance();
};

#endif