#include "include/GPU_world.cuh"

__device__ bool GPU_world::castTypeHit(GenericType* obj, const ray& r, interval ray_t, hit_record& rec)
{
    switch (obj->obj_type)
    {
    case (ObjectType::Sphere):
        sphere* s = (sphere*)obj->object_ptr;
        return s->hit(r, ray_t, rec, obj->mat_ptr, obj->mat_type);
    case (ObjectType::Cube):
        box* b = (box*)obj->object_ptr;
        return b->hit(r, ray_t, rec, obj->mat_ptr, obj->mat_type);
    case (ObjectType::Cylinder):
        cylinder* c = (cylinder*)obj->object_ptr;
        return c->hit(r, ray_t, rec, obj->mat_ptr, obj->mat_type);
    case (ObjectType::Cone):
        cone* con = (cone*)obj->object_ptr;
        return con->hit(r, ray_t, rec, obj->mat_ptr, obj->mat_type);
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
            hit_anything = true;
            closest_so_far = temp_rec.t;
            rec = temp_rec;
        }
    }
    return hit_anything;
}