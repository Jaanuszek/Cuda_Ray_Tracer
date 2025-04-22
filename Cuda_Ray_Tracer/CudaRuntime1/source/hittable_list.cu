#include "include/hittable_list.cuh"

__device__ bool hittable_list::hit(const ray& r, interval ray_t, hit_record& rec) const {
	hit_record temp_rec;
	bool hit_anything = false;
	auto closest_so_far = ray_t.max;
	for (int obj = 0; obj < list_size; obj++)
	{
		if (m_objects_ptr[obj]->hit(r, interval(ray_t.min, closest_so_far), temp_rec)) {
			hit_anything = true;
			closest_so_far = temp_rec.t;
			rec = temp_rec;
		}
	}
	return hit_anything;
}
