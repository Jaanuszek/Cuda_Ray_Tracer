#ifndef HITTABLE_LIST_CUH
#define HITTABLE_LIST_CUH

#include "hittable.cuh"

#include "general_includes.cuh"
#include <vector>

class hittable_list : public hittable
{
public:
	hittable** m_objects_ptr;
	int list_size;
	//__host__ __device__ hittable_list() : m_objects_ptr(nullptr), list_size(0) {}
	__host__ __device__ hittable_list() {}
	__host__ __device__ inline hittable_list(hittable** obj, int n) : m_objects_ptr(obj), list_size(n) {}

	//__host__ __device__ void clear() { m_objects_vec.clear(); }
	//__host__ __device__ void add(std::shared_ptr<hittable> object) { m_objects_vec.push_back(object); }
	__host__ __device__ bool hit(const ray& r, float ray_tmin, float ray_tmax, hit_record& rec) const override;
};

#endif