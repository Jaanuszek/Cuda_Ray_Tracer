#ifndef INTERVAL_CUH
#define INTERVAL_CUH

#include "general_includes.cuh"

class interval {
public:
    float min, max;
    __host__ __device__ interval() : min(+constants::infinity), max(-constants::infinity) {}
    __host__ __device__  interval(float a, float b) : min(a), max(b) {}

    __host__ __device__  float size() const {
        return max - min;
    }

    __host__ __device__  bool contains(float x) const {
        return min <= x && x <= max;
    }

    __host__ __device__  bool surrounds(float x) const {
        return min < x && x < max;
    }

    static const interval empty, universe;
};

#endif