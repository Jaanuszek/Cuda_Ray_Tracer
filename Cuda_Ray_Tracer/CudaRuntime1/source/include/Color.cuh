#ifndef COLOR_CUH
#define COLOR_CUH

#include "general_includes.cuh"
#include "interval.cuh"

//! @file Color.cuh
//! @brief Definicja funkcji pomocniczych do obliczen kolorow
//! @details Klasa color, zawiera metody do obliczen kolorow

using color = vec3;

//! @brief Funkcja konwertujaca kolor z formatu RGB do formatu sRGB
//! @details Funkcja konwertujaca kolor z formatu RGB (linear) do formatu sRGB (gamma).
//! Robi sie tak, by kolory wygladaly lepiej na ekranie.
//! Ludzkie oko nie widzi œwiat³¹ liniowo, dlatego korektor gamma
//! sprawia ¿e kolory wygl¹daj¹ naturalniej dla ludzkiego oka.
//! @param linear_component Sk³adowa koloru w formacie RGB (linear).
__host__ inline float linear_to_gamma(float linear_component)
{
	if (linear_component > 0.0f)
		return std::sqrt(linear_component);
	
	return 0;
}

//! @brief G³ówna funkcja do zapisu koloru
//! @details Funkcja zapisuje kolor w formacie RGB do strumienia wyjœciowego (std::ostream).\
//! Kolor jest konwertowany z formatu linear do formatu gamma (sRGB).
//! @param out Strumieñ wyjœciowy, do którego zostanie zapisany kolor.
//! @param pixel_color Kolor, który ma zostaæ zapisany.
__host__ inline void write_color(std::ostream& out, const color& pixel_color)
{
	float r = linear_to_gamma(pixel_color.x());
	float g = linear_to_gamma(pixel_color.y());
	float b = linear_to_gamma(pixel_color.z());
	
    static const interval intensity(0.0f, 0.999f);
	int rbyte = int(256 * intensity.clamp(r));
	int gbyte = int(256 * intensity.clamp(g));
	int bbyte = int(256 * intensity.clamp(b));

	out << rbyte << ' ' << gbyte << ' ' << bbyte << '\n';
}

#endif