
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

int main()
{
    //GPU_variables::init(400, 300, 2);
    //GPU_variables& gpu_vars = GPU_variables::getInstance();
    //render_params* h_render_params = gpu_vars.getRenderParams();
	camera cam;
	cam.render();
}
