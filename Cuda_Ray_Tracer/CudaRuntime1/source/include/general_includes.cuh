#ifndef GENERAL_INCLUDES_CUH
#define GENERAL_INCLUDES_CUH

#include <cmath>
#include <iostream>
#include <limits>
#include <memory>
#include <random>
#include "cuda_runtime.h"
#include <cuda/std/variant>
#include "vec3.cuh"

//! @file general_includes.cuh
//! @brief Plik nag³owkowy zawieraj¹cy ogolne definicje i funkcje pomocnicze

//! @brief Definicja makra do sprawdzania bledow CUDA
//! @details Makro to sprawdza, czy funkcja CUDA zakonczyla siê sukcesem.
#define checkCudaErrors(val) check_cuda( (val), #val, __FILE__, __LINE__)

//! @brief Typ wyliczeniowy do okreslenia typu wskaznika CUDA
//! @details Typ ten okresla, czy wskaznik jest typu host, device, managed czy unknown.
enum class ptr_type
{
    Unknown = 0,
    Host = 1,
    Device = 2,
    Managed = 3
};

enum class ObjectType
{
    NONE,
    Sphere,
    Cube,
    Cone,
    Cylinder
};

enum class MaterialType
{
    NONE,
    Lambertian,
    Metal,
    Dielectric
};

namespace jsonParserStructs {
    struct parsed_image_params
    {
        int image_width;
        int samples_per_pixel;
    };

    struct parsed_camera_params
    {
        float fov;
        vec3 camera_pos;
        vec3 look_at;
        vec3 vector_up;
    };

    struct LambertianValues
    {
        vec3 Albedo;
    };

    struct MetalValues
    {
        vec3 Albedo;
        float fuzz;
    };

    struct DielectircValues
    {
        float reflaction_index;
    };

    struct Sphere
    {
        vec3 center;
        float radius;
    };

    struct Cube
    {
        vec3 min_vertex;
        vec3 max_vertex;
    };

    struct Cylinder
    {
        vec3 center;
        float radius;
        float height;
    };

    struct Cone
    {
        vec3 center;
        float radius;
        float height;
    };
}

using mat_data_variant = cuda::std::variant<jsonParserStructs::LambertianValues, jsonParserStructs::MetalValues, jsonParserStructs::DielectircValues>;
using obj_data_variant = cuda::std::variant<jsonParserStructs::Sphere, jsonParserStructs::Cube, jsonParserStructs::Cylinder, jsonParserStructs::Cone>;

struct ShapeWrapper
{
    MaterialType mat_type;
    mat_data_variant mat_data;
    ObjectType obj_type;
    obj_data_variant obj_data;
};

//! @brief Funkcja sprawdzajaca bledy CUDA
//! @details Funkcja ta sprawdza, czy funkcja CUDA zakonczy³a sie sukcesem.
//! Jesli nie, wypisuje komunikat o bledzie i konczy program.
inline void check_cuda(cudaError_t result, const char* func, const char* file, const int line)
{
    // spróbowac kiedys tutaj dodaæ rzucanie wyj¹tku a nie exit, ale to tak dla sportu
    if (result != cudaSuccess) {
        std::cerr << "CUDA error (" << static_cast<unsigned int>(result) << "): "
            << cudaGetErrorString(result)
            << " at " << file << ":" << line
            << " in call to '" << func << "'\n";
        cudaDeviceReset();
        exit(EXIT_FAILURE);
    }
}

//! @brief Funkcja sprawdzaj¹ca typ wskaŸnika CUDA
//! @details Funkcja ta sprawdza, czy wskaznik jest typu host, device, managed czy unknown.
//! Zwraca odpowiedni typ wyliczeniowy ptr_type.
//! Nie wykorzystany w projekcie.
//! @param ptr Wskaznik, którego typ ma zostaæ sprawdzony.
inline ptr_type check_ptr_type(void* ptr)
{
    cudaPointerAttributes attributes;
    cudaError_t result = cudaPointerGetAttributes(&attributes, ptr);
    if (result != cudaSuccess) {
        std::cerr << "Error getting pointer attributes: " << cudaGetErrorString(result) << std::endl;
        return ptr_type::Unknown;
    }
    std::cout << attributes.type << std::endl;
    switch (attributes.type) {
    case cudaMemoryTypeHost:
        return ptr_type::Host;
    case cudaMemoryTypeDevice:
        return ptr_type::Device;
    case cudaMemoryTypeManaged:
        return ptr_type::Managed;
    default:
        std::cerr << "Unknown pointer type" << std::endl;
        return ptr_type::Unknown;
    }
}

//! @brief Struktura przechowuj¹ca sta³e
namespace constants {
    constexpr float infinity = std::numeric_limits<float>::infinity();
    constexpr float pi = 3.1415926535897932385f;
}
__host__ __device__ inline float degrees_to_radians(float degrees) {
    return degrees * constants::pi / 180.0f;
}

#endif
