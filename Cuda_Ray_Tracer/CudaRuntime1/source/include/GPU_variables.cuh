#ifndef GPU_VARIABLES_CUH
#define GPU_VARIABLES_CUH

#include <curand_kernel.h>
#include "general_includes.cuh"
#include "hittable.cuh"
#include "hittable_list.cuh"
#include "sphere.cuh"

class camera;

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
    render_params* h_render_params;
    render_params* d_render_params; // to raczej sie narazie nie przyda ale zostawie na przyszlosc
    static GPU_variables* instance;
    __host__ GPU_variables(int width, int height, int objCount);
    __host__ ~GPU_variables();
public:
    __host__ GPU_variables(const GPU_variables&) = delete;
    __host__ GPU_variables& operator=(const GPU_variables&) = delete;
    __host__ static void init(int width, int height, int objCount);
    __host__ static GPU_variables& getInstance();
    __host__ __device__ render_params* getRenderParams() const { return h_render_params; }
    __host__ void destroy();
};

#endif