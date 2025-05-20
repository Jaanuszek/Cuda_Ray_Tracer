#ifndef MATERIAL_CUH
#define MATERIAL_CUH

//#include "hittable.cuh"
//#include "ray.cuh"

//! @file material.cuh
//! @brief Definicja klasy material oraz funkcji scatter

//! @brief Klasa material jest klasa bazowa dla wszystkich materialow.
//! @details Klasa material jest klasa bazowa dla wszystkich materialow. Zawiera abstrakcyjna funkcje scatter,
//! ktora z zalozenia jest odpowiedzialna za rozproszenie promienia w zaleznosci od materialu.
//class material {
//public:
//	__device__ virtual bool scatter(
//		const ray& r_in, const hit_record& rec,
//		vec3& attenuation, ray& scattered,
//		curandState* r_state
//		) const = 0;
//
//	__host__ __device__ virtual bool host_device_scatter(
//		const ray& r_in, const hit_record& rec,
//		vec3& attenuation, ray& scattered,
//		curandState* r_state
//	) const = 0;
//};

#endif