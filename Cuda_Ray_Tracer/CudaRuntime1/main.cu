
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <curand_kernel.h>

#include <stdio.h>
#include "source/include/general_includes.cuh"
#include <vector>
#include "source/include/hittable.cuh"
#include "source/include/sphere.cuh"
#include "source/include/camera.cuh"
#include "source/include/GPU_variables.cuh"
#include "source/include/lambertian.cuh"
#include "source/include/metal.cuh"
#include "source/include/GPU_factory.cuh"
#include "source/include/GPU_world.cuh"
#include "source/include/json.hpp"
#include "source/include/JsonParser.cuh"

int main()
{
    std::string JsonFilePath = __FILE__;
    JsonFilePath = JsonFilePath.substr(0, JsonFilePath.find_last_of("/\\"));
    JsonFilePath = JsonFilePath + "\\JSON_config\\cuda_ray_tracer_JSON.json";

    JsonParser parser(JsonFilePath);
    ParsedData parsed_data = parser.getParsedData();
    std::vector<ShapeWrapper> test = parsed_data.shapesVector;

    camera_essentials cam_params;
    cam_params.image_width = parsed_data.img_params.image_width;
    cam_params.samples_per_pixels = parsed_data.img_params.samples_per_pixel;
    cam_params.fov = parsed_data.cam_params.fov;
    cam_params.camera_pos = parsed_data.cam_params.camera_pos;
    cam_params.look_at = parsed_data.cam_params.look_at;
    cam_params.up = parsed_data.cam_params.vector_up;

    GPU_factory gpu_factory;
    gpu_factory.CreateAndGetScene(parsed_data.shapesVector);
    std::vector<GenericType> gpu_scene = gpu_factory.getGpuScene();
    GenericType* d_obj = gpu_factory.uploadArrayToGPU(gpu_scene.data(), gpu_scene.size());
    GPU_world h_scene(d_obj, gpu_scene.size());
    GPU_world* d_scene = gpu_factory.uploadToGPU(h_scene);

    camera cam(cam_params, d_scene);
    cam.render();
}