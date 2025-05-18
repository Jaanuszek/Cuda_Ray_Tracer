#ifndef GPU_WORLD_CUH
#define GPU_WORLD_CUH

#include "GPU_factory.cuh"

// Chcialbym tutaj wlasnie zaimplementowac parser JSON zeby za pomoca jsona tworzyc kolejne obiekty itp

class GPU_world
{
private:
    //GenericType* device_scene_ptr;
    //size_t scene_size;
public:
    GenericType* device_scene_ptr;
    size_t scene_size;
    __host__ GPU_world(GenericType* d_scene, size_t sceneSize) : device_scene_ptr(d_scene), scene_size(sceneSize) {}
    __device__ bool castTypeHit(GenericType* obj, const ray& r, interval ray_t, hit_record& rec);
    __device__ bool hit(const ray& r, interval ray_t, hit_record& rec);
};


#endif