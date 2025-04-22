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
	__device__ hittable_list() :m_objects_ptr(nullptr), list_size(0) {}
	__device__ inline hittable_list(hittable** obj, int n) : m_objects_ptr(obj), list_size(n) {}

	__device__ bool hit(const ray& r, interval ray_t, hit_record& rec) const override;
};

#endif