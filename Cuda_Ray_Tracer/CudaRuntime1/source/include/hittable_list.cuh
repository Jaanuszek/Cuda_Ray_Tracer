//#ifndef HITTABLE_LIST_CUH
//#define HITTABLE_LIST_CUH
//
//#include "hittable.cuh"
//
//#include "general_includes.cuh"
//#include "ray.cuh"
//#include <vector>
////! @file hittable_list.cuh
////! @brief Definicja klasy hittable_list
//
////!@brief Klasa hittable_list jest lista obiektow, ktore moga byc trafione przez promien.
////! @details Klasa hittable_list jest lista obiektow, ktore moga byc trafione przez promien.
////! Przechowuje tablice wskaznikow na obiekty w niej zawarte oraz przeciazona funkcje hit.
////! Klasa dziedziczy po hittable.
////! 
//// !!!!!!!!!!!!!! KLASA ZASTAPIONA PRZEZ GPU_WORLD.CUH!!!!!!!!!!!!!!!!!!!!1
//class hittable_list : public hittable
//{
//public:
//    hittable** m_objects_ptr;
//    int list_size;
//    __device__ hittable_list() :m_objects_ptr(nullptr), list_size(0) {}
//    __device__ inline hittable_list(hittable** obj, int n) : m_objects_ptr(obj), list_size(n) {}
//
//    //! @brief Przeciazona funkcja sprawdzajaca czy promien trafia w obiekt zawarty w tej liscie.
//    __device__ bool hit(const ray& r, interval ray_t, hit_record& rec) const override;
//};
//
//#endif