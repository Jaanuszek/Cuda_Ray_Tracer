#ifndef METAL_CUH
#define METAL_CUH

#include "material.cuh"

//! @file metal.cuh
//! @brief Definicja klasy metal (metal)

//! @brief Definicja klasy metal
//! @details Klasa metal dziedziczy po klasie material. Przechowuje informacje o albedo (kolorze) materialu oraz jego "szorstkoœci" (fuzz).
class metal : public material {
private:
	vec3 albedo;
	float fuzz;
public:
    //! @brief Konstruktor klasy metal, przyjmujaca kolor albedo oraz "szorstkoœæ" fuzz ktora jest ograniczona do wartosci 1.
	__host__ __device__ metal(const vec3& albedo, float fuzz) : albedo(albedo), fuzz(fuzz < 1 ? fuzz : 1) {}

	//! @brief Przeciazona funkcja scatter, ktora oblicza oraz odbija promien.
    //! @details W przypadku gdy fuzz jest rowny 0, to promien jest idealnie odbijany (powstaje efekt lustrzany).
    //! Jezeli jednak fuzz jest wiekszy niz zero, to promien jest odbijany w losowym kierunku, przez co powstaje efekt rozproszenia swiatla
	//! a w konsekwencji brak idealnego zjawiska lustra.
	__device__ bool scatter(
		const ray& r_in, const hit_record& rec,
		vec3& attenuation, ray& scattered,
		curandState* r_state
	) const override
	{
		vec3 reflected = reflect(r_in.get_direction(), rec.normal);
        reflected = unit_vector(reflected) + (fuzz * random_unit_vec(r_state));
		scattered = ray(rec.p, reflected);
		attenuation = albedo;
		return (dot(scattered.get_direction(), rec.normal) > 0);
	}
};

#endif