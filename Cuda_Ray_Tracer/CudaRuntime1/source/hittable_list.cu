#include "include/hittable_list.cuh"

bool hittable_list::hit(const ray& r, float ray_tmin, float ray_tmax, hit_record& rec) const {
	hit_record temp_rec;
	bool hit_anything = false;
	auto closest_so_far = ray_tmax;
	for (const auto& object : m_objects) {
		if (object->hit(r, ray_tmin, closest_so_far, temp_rec)) {
			hit_anything = true;
			closest_so_far = temp_rec.t;
			rec = temp_rec;
		}
	}
	return hit_anything;
}
