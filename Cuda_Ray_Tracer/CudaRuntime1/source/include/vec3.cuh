#ifndef VEC3_CUH
#define VEC3_CUH

#include <cstddef>
#include "general_includes.cuh"
#include "cuda_runtime.h"
#include <curand_kernel.h>
#include "device_launch_parameters.h"

class vec3 {
private:
    float element[3];
public:
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
    __device__ bool near_zero() const
    {
        float s = 1e-8;
        return (fabs(element[0]) < s &&
                fabs(element[1]) < s &&
                fabs(element[2]) < s);
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

__device__ inline vec3 random_unit_vec(curandState* r_state)
{
    while (true)
    {
        vec3 p(
            2 * curand_uniform(r_state) - 1.0f,
            2 * curand_uniform(r_state) - 1.0f,
            2 * curand_uniform(r_state) - 1.0f
        );
        if (p.length_squared() <= 1)
            return p / sqrt(p.length_squared());
    }
}

__device__ inline vec3 random_on_hemisphere(const vec3& normal, curandState* r_state)
{
    vec3 rand_vec = random_unit_vec(r_state);
    if (dot(rand_vec, normal) > 0.0f)
    {
        return rand_vec;
    }
    else
    {
        return -rand_vec;
    }
}

// Dot zwraca skalar. Mno¿¹c to razy N, otrzymujemy wektor równoleg³y do normalnej
// -, bo chcemy zeby wektor wynikowy byl skierowany od powierzchni
// dot(v,n) * n to jest czêœæ V któa idzie w kierunku N
// mnozymy razy dwa, bo inaczej nie moglby powstac promien odbity
// powstalby taki wektor skierowany w prawo przy powierzchni - bez snesu
__device__ inline vec3 reflect(const vec3& v, const vec3& n)
{
    return v - 2 * dot(v, n) * n;
}

// uv promien padaj¹cy
// n normalna
// etai_over_etat wspó³czynnik za³amania
// dot(-uv,n) minus przed uv, bo chcemy kat miedzy promieniem nadchodz¹cym do powierzchni a normaln¹
// bez tego minusa, wartosc dot by³aby ujemna.
__device__ inline vec3 refract(const vec3& uv, const vec3& n, float etai_over_etat)
{
    float cos_theta = fminf(dot(-uv, n), 1.0f);
    vec3 r_out_perp = etai_over_etat * (uv + cos_theta * n);
    vec3 r_out_parallel = -sqrtf(fabs(1.0f - r_out_perp.length_squared())) * n;
    return r_out_perp + r_out_parallel;
}

#endif