#ifndef SPHERE_CUH
#define SPHERE_CUH


#include "general_includes.cuh"
#include "hittable.cuh"
#include "vec3.cuh"
#include "ray.cuh"

//! @file sphere.cuh
//! @brief Definicja klasy sphere

//! @brief Klasa sphere reprezentuje sferê w przestrzeni 3D
//! @details Klasa sphere dziedziczy po klasie hittable. Przechowuje informacje o sferze, takie jak:
//! srodek sfery, promien oraz material.
class sphere : public hittable
{
private:
    point3 m_center;
    float m_radius;
public:
    material* mat_ptr;
    __device__ __host__ sphere(const point3& center, float radius, material* mat);
    __device__ __host__ ~sphere() { delete mat_ptr; mat_ptr = nullptr; }

    //! @brief Przeciazona funkcja sprawdzajaca czy promien trafia w sferê
    //! @details Funkcja korzysta z rownania okregu, obliczajac przestrzen w ktorej sie znajduje dana kula, bazujac na pozycji jej srodka.
    //! Przyjmuje referencje na promien oraz czas, w ktorym promien trafia w obiekt.
    //! Jezeli promien trafi w obiekt, ustawia informacje o trafieniu w obiekcie (hit_record& rec).
    //! Zwraca true, jezeli promien trafi w obiekt, false w przeciwnym razie.
    __device__ bool hit(const ray& r, interval ray_t, hit_record& rec) const override;
};

#endif