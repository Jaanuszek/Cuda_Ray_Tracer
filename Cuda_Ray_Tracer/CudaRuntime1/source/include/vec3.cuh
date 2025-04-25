#ifndef VEC3_CUH
#define VEC3_CUH

#include <cstddef>

#include "general_includes.cuh"
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

class vec3 {
private:
	float element[3];
public:
	//float m_x, m_y, m_z;
	__host__ __device__ vec3() : element{ 0,0,0 } {}
	__host__ __device__ vec3(float x, float y, float z) : element{ x,y,z } {}

	__host__ __device__ float x() const { return element[0]; }
	__host__ __device__ float y() const { return element[1]; }
	__host__ __device__ float z() const { return element[2]; }

	__host__ __device__ vec3 operator-() const { return vec3(-element[0], -element[1], -element[2]); }
	__host__ __device__ float operator[](std::size_t i) const { return element[i]; }
	__host__ __device__ float& operator[](std::size_t i) { return element[i]; }

	__host__ __device__ vec3& operator+=(const vec3& v) {
		element[0] += v.element[0];
		element[1] += v.element[1];
		element[2] += v.element[2];
		return *this;
	}

	__host__ __device__ vec3& operator*=(const float t) {
		element[0] *= t;
		element[1] *= t;
		element[2] *= t;
		return *this;
	}

	__host__ __device__ vec3& operator/=(const float t) {
		return *this *= 1 / t;
	}

	__host__ __device__ float length() const {
		return sqrtf(length_squared());
	}

	__host__ __device__ float length_squared() const {
		return element[0] * element[0] + element[1] * element[1] + element[2] * element[2];
	}
};

using point3 = vec3;

inline std::ostream& operator <<(std::ostream& out, const vec3& v)
{
	return out << v.x() << ' ' << v.y() << ' ' << v.z();
}

__host__ __device__ inline vec3 operator+(const vec3& u, const vec3& v) {
	return vec3(u.x() + v.x(), u.y() + v.y(), u.z() + v.z());
}

__host__ __device__ inline vec3 operator-(const vec3& u, const vec3& v) {
	return vec3(u.x() - v.x(), u.y() - v.y(), u.z() - v.z());
}

__host__ __device__ inline vec3 operator*(const vec3& u, const vec3& v) {
	return vec3(u.x() * v.x(), u.y() * v.y(), u.z() * v.z());
}

__host__ __device__ inline vec3 operator*(float t, const vec3& v) {
	return vec3(t * v.x(), t * v.y(), t * v.z());
}

__host__ __device__ inline vec3 operator*(const vec3& v, float t) {
	return t * v;
}

__host__ __device__ inline vec3 operator/(const vec3& v, float t) {
	return (1 / t) * v;
}

__host__ __device__ inline float dot(const vec3& u, const vec3& v) {
	return u.x() * v.x() + u.y() * v.y() + u.z() * v.z();
}

__host__ __device__ inline vec3 cross(const vec3& u, const vec3& v) {
	return vec3(u.y() * v.z() - u.z() * v.y(),
		u.z() * v.x() - u.x() * v.z(),
		u.x() * v.y() - u.y() * v.x());
}

__host__ __device__ inline vec3 unit_vector(vec3 v) {
	return v / v.length();
}

#endif