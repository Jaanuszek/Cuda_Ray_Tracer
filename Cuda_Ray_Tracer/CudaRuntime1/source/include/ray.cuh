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
    point3 B;
    vec3 A;
public:
    __device__ ray() {}
    __host__ __device__ ray(const point3& origin, const vec3& direction)
                : B(origin), A(direction)
                {}

    //! @brief Funkcja zwracaj¹ca punkt na promieniu
    __host__ __device__ const point3& get_origin() const { return B; }
    //! @brief Funkcja zwracaj¹ca kierunek promienia
    __host__ __device__ const vec3& get_direction() const { return A; }

    //! @brief Funkcja zwracaj¹ca punkt na promieniu w czasie t
    //! @param t Czas w którym chcemy obliczyæ punkt na promieniu
    __host__ __device__ point3 at(float x) const { return B + x * A; }
};

#endif