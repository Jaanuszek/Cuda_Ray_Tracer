#ifndef GENERAL_INCLUDES_CUH
#define GENERAL_INCLUDES_CUH

#include <cmath>
#include <iostream>
#include <limits>
#include <memory>
#include <random>
#include "cuda_runtime.h"

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