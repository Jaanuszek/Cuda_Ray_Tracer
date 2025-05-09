#ifndef HITTABLE_CUH
#define HITTABLE_CUH


#include "general_includes.cuh"
#include "vec3.cuh"
#include "ray.cuh"
#include "interval.cuh"

//! @file hittable.cuh
//! @brief Definicja klasy hittable oraz hit_record
class material;

//! @brief Klasa przechowujaca informacje o trafieniu promienia w obiekt
//! @details Klasa przechowuje informacje o punkcie trafienia, normalnej w tym punkcie,
//! wskazniku na material, czasie trafienia oraz flage front_face ktora mowi o tym czy promien trafil w obiekt od przodu czy od tylu.
class hit_record
{
public:
	point3 p; // hit point
	vec3 normal; // normal at hit point
	material* mat_ptr;
	float t;
	bool front_face;

    //! @brief Funkcja ustawia normalna w punkcie trafienia
    //! @details Funkcja ustawia normalna w punkcie trafienia, oraz flage front_face. Jezeli front_face jest ujemny
	//! to normalna jest negowana, by byla zawsze na zewnatrz obiektu.
	__device__ void set_face_normal(const ray& r, const vec3& outward_normal)
	{
		front_face = dot(r.get_direction(), outward_normal) < 0.0f;
		normal = front_face ? outward_normal : -outward_normal;
	}
};

//! @brief Klasa bazowa dla wszystkich obiektow, ktore moga byc trafione przez promien
class hittable
{
public:
    //! @brief Funkcja czyszczaca pamiec
	//! @details Nie moze byc to wirtualny destruktor, bo cuda sobie z tym nie radzi.
	__device__ ~hittable() {}
    //! @brief Abstrakcyjna funkcja sprawdzajaca czy promien trafil w obiekt
    //! @details Funkcja sprawdza czy promien trafia w obiekt. Jezeli tak, to ustawia informacje o trafieniu w obiekcie.
	__device__ virtual bool hit(const ray& r, interval ray_t, hit_record& rec) const = 0;
};

#endif // !HITTABLE_CUH
