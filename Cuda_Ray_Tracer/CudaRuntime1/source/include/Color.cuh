#ifndef COLOR_CUH
#define COLOR_CUH

#include "general_includes.cuh"
#include "interval.cuh"

using color = vec3;

__host__ inline void write_color(std::ostream& out, const color& pixel_color)
{
	float r = pixel_color.x();
	float g = pixel_color.y();
	float b = pixel_color.z();
	
    static const interval intensity(0.0f, 0.999f);
	int rbyte = int(256 * intensity.clamp(r));
	int gbyte = int(256 * intensity.clamp(g));
	int bbyte = int(256 * intensity.clamp(b));

	out << rbyte << ' ' << gbyte << ' ' << bbyte << '\n';
}

#endif