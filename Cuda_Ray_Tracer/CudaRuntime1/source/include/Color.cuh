#ifndef COLOR_CUH
#define COLOR_CUH


#include "general_includes.cuh"

using color = vec3;

__host__ inline void write_color(std::ostream& out, const color& pixel_color)
{
	float r = pixel_color.x();
	float g = pixel_color.y();
	float b = pixel_color.z();
	
	int rbyte = int(255.999 * r);
	int gbyte = int(255.999 * g);
	int bbyte = int(255.999 * b);

	out << rbyte << ' ' << gbyte << ' ' << bbyte << '\n';
}

#endif