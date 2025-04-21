#ifndef HITTABLE_LIST_CUH
#define HITTABLE_LIST_CUH

#include "hittable.cuh"
#include <memory>
#include <vector>

class hittable_list : public hittable
{
private:
	std::vector<std::shared_ptr<hittable>> m_objects;
public:
	__host__ __device__ hittable_list() = default;
	__host__ __device__ hittable_list(std::shared_ptr <hittable> object) : m_objects{ object } {}

	__host__ __device__ void clear() { m_objects.clear(); }
	__host__ __device__ void add(std::shared_ptr<hittable> object) { m_objects.push_back(object); }
	__host__ __device__ bool hit(const ray& r, float ray_tmin, float ray_tmax, hit_record& rec) const override;
};

#endif