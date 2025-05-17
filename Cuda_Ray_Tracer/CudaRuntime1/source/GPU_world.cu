#include "include/GPU_world.cuh"


//__device__ void* GPU_world::checkMatType(GenericType* obj)
//{
//    switch (obj->mat_type)
//    {
//    case(MaterialType::Lambertian):
//        return (lambertian*)obj->mat_ptr;
//    case(MaterialType::Metal):
//        return (metal*)obj->mat_ptr;
//    case(MaterialType::Dielectric):
//        return (dielectric*)obj->mat_ptr;
//    default:
//        return nullptr;
//    }
//}

__device__ bool GPU_world::castTypeHit(GenericType* obj, const ray& r, interval ray_t, hit_record& rec)
{
    switch (obj->obj_type)
    {
    case (ObjectType::Sphere):
        //printf("======== castTypeHit-1\n");
        sphere* s = (sphere*)obj->object_ptr;
        //printf("======== castTypeHit0\n");
        //void* mat = checkMatType(obj);
        //printf("======== castTypeHit1\n");
        return s->hit(r, ray_t, rec, obj->mat_ptr, obj->mat_type);
    default:
        return false;
    }
}

__device__ bool GPU_world::hit(const ray& r, interval ray_t, hit_record& rec)
{
    hit_record temp_rec;
    bool hit_anything = false;
    auto closest_so_far = ray_t.max;
    for(int i = 0 ; i < scene_size; i++)
    {
        if (castTypeHit(&device_scene_ptr[i], r, interval(ray_t.min, closest_so_far), temp_rec))
        {
            //printf("======== hit1 \n");
            hit_anything = true;
            closest_so_far = temp_rec.t;
            rec = temp_rec;
        }
    }
    return hit_anything;
}