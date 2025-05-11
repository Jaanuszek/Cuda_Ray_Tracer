#ifndef GPU_VARIABLES_CUH
#define GPU_VARIABLES_CUH

#include <random>
#include <vector>
#include <memory>
#include <curand_kernel.h>
#include "general_includes.cuh"
#include "hittable.cuh"
#include "hittable_list.cuh"
#include "sphere.cuh"
#include "material.cuh"
#include "lambertian.cuh"
#include "dielectric.cuh"
#include "metal.cuh"

//! @file GPU_variables.cuh
//! @brief Plik naglowkowy zawierajacy definicje singletona GPU_variables
//! @details Klasa ta jest singletonem, ktory przechowuje zmienne inicjalizowane i przechowywane na GPU
//! uzywane w programie.
class camera;

//! @brief Struktura przechowujaca parametry renderowania
//! @details Struktura ta przechowuje wskazniki do zmiennych inicjalizowanych i przechowywanych na GPU.
//! Stworzona w celu uproszczenia kodu i zmniejszenia ilosci przekazywanych argumentow do funkcji.
struct render_params
{
    curandState* rand_state;
    hittable** list;
    hittable_list* world;
    vec3* fb;
    //camera* camera;
};

//! @brief Klasa realizujaca wzorzec Singletona
class GPU_variables
{
private:
    int image_width;
    int image_height;
    int objectCount;
    render_params* h_render_params;
    render_params* d_render_params;
    //std::vector<hittable*> h_list;
    //std::vector<hittable_list> h_world;
    hittable_list* h_world;
    //std::shared_ptr<hittable_list> h_world;
    hittable** h_list;
    //hittable_list* h_world;
    static GPU_variables* instance;
    //! @brief Prywatny konstruktor klasy GPU_variables
    //! @details inicjuje wskaznik do struktury render_params
    //! Alokuje pamiec na GPU dla zmiennych przechowywanych w tej strukturze
    __host__ GPU_variables(int width, int height, int objCount);
    //! @brief Prywatny destruktor klasy GPU_variables
    //! @details Zwalnia pamiec na GPU dla zmiennych przechowywanych w strukturze render_params
    __host__ ~GPU_variables();
    //__host__ __device__ std::shared_ptr<hittable_list> create_world(std::vector<hittable*>& list,int sphereWidth, int sphereHeight);
    __host__ __device__ hittable_list* create_world(hittable** list,int sphereWidth, int sphereHeight);
public:
    __host__ GPU_variables(const GPU_variables&) = delete;
    __host__ GPU_variables& operator=(const GPU_variables&) = delete;
    __host__ static void init(int width, int height, int objCount);
    __host__ static GPU_variables& getInstance();
    __host__ __device__ render_params* getRenderParams() const { return h_render_params; }
    __host__ void destroy();
};

#endif