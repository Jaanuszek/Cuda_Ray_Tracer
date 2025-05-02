#include "include/interval.cuh"

const interval interval::empty = interval(+constants::infinity, -constants::infinity);
const interval interval::universe = interval(-constants::infinity, +constants::infinity);

__host__ __device__ float interval::clamp(float x) const
{
    if (x < min) return min;
    if (x > max) return max;
    return x;
}