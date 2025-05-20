#ifndef RAY_CUH
#define RAY_CUH

#include "vec3.cuh"

//! @file ray.cuh
//! @brief Definicja klasy ray
//! @details Klasa ray, zawiera metody do obliczen promieni

// Ray formula P(t) = A + t * b
// // Where P(t) is ray position in time
// A is origin
// b is direction
// I'll change that to P(t) = A * x + B
// so A will be direction
// and B will be origin

//! @brief Klasa ray
//! ! @details Klasa ray, zawiera metody do obliczen promieni
class ray {
private:
    //point3 B;
    //vec3 A;
public:
    point3 B;
    vec3 A;
    vec3 invdir;
    int sign[3];
    __device__ ray() {}
    __host__ __device__ ray(const point3& origin, const vec3& direction)
                : B(origin), A(direction)
    {
        invdir = 1.0f / A;
        sign[0] = (invdir.x() < 0);
        sign[1] = (invdir.y() < 0);
        sign[2] = (invdir.z() < 0);
    }

    //! @brief Funkcja zwracaj¹ca punkt na promieniu
    __host__ __device__ const point3& get_origin() const { return B; }
    //! @brief Funkcja zwracaj¹ca kierunek promienia
    __host__ __device__ const vec3& get_direction() const { return A; }

    //! @brief Funkcja zwracaj¹ca punkt na promieniu w czasie t
    //! @param t Czas w którym chcemy obliczyæ punkt na promieniu
    __host__ __device__ point3 at(float x) const { return B + x * A; }
};

#endif