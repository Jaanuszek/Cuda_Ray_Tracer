
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
    // zmienic te magiczne wartosci by byly zgodne z tymi co sa w klasie "CAMERA"
    int xSpheresCount = 10;
    int ySpheresCount = 10;
    int basicSpheresCount = 5;
    //GPU_variables::init(400, 400, basicSpheresCount + xSpheresCount * ySpheresCount);
    //GPU_variables& gpuVars = GPU_variables::getInstance();
    //gpuVars.destroy();
    //h_create_world(gpuVars.getRenderParams(), xSpheresCount, ySpheresCount);
    camera cam;
    cam.render();
}
