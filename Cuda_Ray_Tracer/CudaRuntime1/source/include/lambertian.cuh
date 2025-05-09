#ifndef LAMBERTIAN_CUH
#define LAMBERTIAN_CUH

#include "material.cuh"

//! @file lambertian.cuh
//! @brief Definicja klasy lambertian (diffuse material)

// Diffuse
//! @brief Klasa lambertian dziedziczy po klasie material. Przechowuje informacje o albedo (kolorze) materialu.
class lambertian : public material {
private:
	vec3 albedo; // "Whiteness"
public:
	__device__ lambertian(const vec3& albedo) : albedo(albedo) {}
    //! @brief Przeciazona funkcja sprawdzajaca czy promien trafia w obiekt
    //! @details Oblicza w sposob losowy kierunek rozproszenia promienia, bazujac na normalnej w punkcie trafienia.
	__device__ bool scatter(
		const ray& r_in, const hit_record& rec, 
		vec3& attenuation, ray& scattered,
		curandState* r_state
	) const override
	{
		vec3 scatter_direction = rec.normal + random_unit_vec(r_state);
		if (scatter_direction.near_zero())
		{
			scatter_direction = rec.normal;
		}
		scattered = ray(rec.p, scatter_direction);
		attenuation = albedo;
		return true;
	}
};

#endif