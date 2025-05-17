#ifndef CAMERA_CUH
#define CAMERA_CUH

#include <curand_kernel.h>
#include "general_includes.cuh"
#include "vec3.cuh"
#include "Color.cuh"
#include "ray.cuh"
#include "hittable.cuh"
#include "sphere.cuh"
#include "hittable_list.cuh"
#include "material.cuh"
#include "GPU_world.cuh"

//! @file camera.cuh
//! Definicja klasy camera oraz namespace renderKernelFunctions.

//! @brief Struktura przechowujaca parametry kamery
//! @details Struktura camera_params przechowuje parametry kamery, takie jak:
//! szerokosc i wysokosc obrazu, srodek kamery, lokalizacje piksela 00 (lewy górny róg),
//! delta piksela w kierunku u i v oraz liczbe probek na piksel (potrzebne przy anty aliasingu).
struct camera_params {
    int image_width;
    int image_height;
    point3 cameraCenter;
    vec3 pixel00_loc;
    vec3 pixel_delta_u;
    vec3 pixel_delta_v;
    int samples_per_pixel;
};

class camera;

//! @brief Przestrzen nazw zawierajaca funkcje kernelowe do renderowania
namespace renderKernelFunctions {
    //! @brief Funkcja obliczajaca kolor promienia
    //! @details Funkcja oblicza kolor konkretnego piksela na podstawie zasad panujacych w ray tracingu.
    //! Jezeli badany promien trafi w obiekt, ktory znajduje sie na scenie, to funkcja odbija promien
    //! w zaleznosci od materialu, ktory znajduje sie na tym obiekcie.
    //! Jezeli jednak promien nie trafil w obiekt, zwracany jest kolor tla.
    //! Dodatkowo, w cudzie wystepuja pewne ograniczenia zwiazane z wywolywaniem funkcji rekursywnych wewnatrz kenrela.
    //! Dlatego zastosowano petle, ktora ogranicza ilosc odbic do okreslonej liczby.
    __device__ color ray_color(const ray& r, GPU_world* world, curandState* r_state);
    //! @brief Funkcja inicjalizujaca stan generatora liczb losowych
    //! @details Funkcja tworzy generator liczb losowych, ktory moze byc wykorzystywany po stronie GPU
    __global__ void init_rand_state(curandState* rand_state, int width, int height);
    //! @brief Funkcja renderujaca bufor ramki
    //! @details Funkcja jest glownym kernelem programu. Kazde wywolanie funkcji oblicza jeden piksel.
    //! Funkcja oblicza indeksy badanych pikseli, promien jaki pada na dany piksel, oraz kolor przy pomocy funkcji
    //! ray_color. Kolor jest zapisywany w tablicy d_fb. Zastosowano dodatkowo petle, ktora wraz z generowaniem liczb losowych
    //! tworzy filtr antyliasingowy, dzieki ktoremu krawedzie obiektow sa interpolowane i wygladzane.
    __global__ void render_framebuffer(vec3* d_fb, GPU_world* d_world, camera_params camParams, curandState* rand_state);
    ////! @brief Funkcja tworzy zmienne przechowywane na GPU
    ////! @details Funkcja inicjalizuje obiekty klas, oraz liste obiektow (d_list) przechowywanych na scenie (d_world).
    ////! Obiekty klas sa wykorzystywane na GPU, dlatego nalezalo zaalokowac ich pamiec na GPU. W tym miejscu, mozliwe jest 
    ////! dodanie, ustawianie pozycji i materialow obiektow, ktore maja byc renderowane.
    //__global__ void create_world(hittable** d_list, hittable** d_world, curandState* rand_state);
    ////! @brief Funkcja czyszczaca pamiec GPU
    ////! @details Funkcja zwalnia pamiec GPU, ktora byla zaalokowana dla obiektow klas, oraz listy obiektow w kernelu create_world.
    //__global__ void clear_world(hittable** d_list, hittable** d_world);
}

//! @brief Klasa camera
//! @details Klasa camera jest odpowiedzialna za renderowanie sceny. Zawiera wszystkie parametry kamery.
class camera {
private:
    int image_height;
    point3 cameraCenter;
    point3 pixel00_loc;
    vec3 pixel_delta_u;
    vec3 pixel_delta_v;
    float piexel_samples_scale;
    vec3 u, v, w;

    dim3 blockSize;
    dim3 gridSize;

    GPU_world* d_scene;

    //! @brief Funkcja inicjalizujaca i obliczajaca parametry kamery
    void Init();
    //! @brief Funkcja obliczajaca i zwracajaca promien
    __device__ ray get_ray(int index_i, int index_j, float offset_x, float offset_y) const;
public:
    float aspect_ratio = 16.0f / 9.0f;
    int image_width = 800;
    int samples_per_pixel = 100;
    float vfov = 80.0f;
    vec3 lookfrom = vec3(0, 2, 1);
    vec3 lookat = vec3(0, 0, -2);
    vec3 vup = vec3(0, 1, 0);

    //! @brief Konstruktor klasy camera
    //! @details tworzy obiekt signletona oraz wywoluje kernele inicjalizujace: "create_world" oraz "init_rand_state"
    __host__  camera(GPU_world* d_world);
    //! @brief Destruktor klasy camera
    //! @details zwalnia pamiec GPU, ktora byla zaalokowana dla obiektow klas, oraz listy obiektow w kernelu create_world.
    __host__  ~camera();

    //! @brief Funkcja renderujaca, zwracajaca wynikowy obraz.
    //! @details Funkcja kopiuje obliczona w kernelu "render_framebuffer" tablice d_fb na CPU, iteruje po niej oraz wypisuje
    //! na standardowe wyjscie konkretne wartosci RGB dla kazdego piksela. Obraz wynikowy jest w formacie PPM.
    //! W celu sprawdzenia poprawnosci dzialania programu, nalezy uruchomic program oraz przekierowac jego wyjscie do pliku.
    //! Nastepnie nalezy wgrac plik do PPM P3 viewer (np. https://www.cs.rhodes.edu/welshc/COMP141_F16/ppmReader.html)
    __host__ void render();
};

#endif