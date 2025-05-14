#ifndef INTERVAL_CUH
#define INTERVAL_CUH

#include "general_includes.cuh"

//! @file interval.cuh
//! @brief Definicja pomocniczej klasy interval

//! @brief Klasa interval jest pomocnicza klasa, ktora przechowuje informacje o zdefiniowanym przedziale.
class interval {
public:
    float min, max;
    //! @brief Domyslny konstruktor klasy interval, w ktorzym przedzial jest zdefiniowany jako nieskonczony
    __host__ __device__ interval() : min(+constants::infinity), max(-constants::infinity) {}
    //! @brief Konstruktor klasy interval ze zdefiniowanymi wartosciami przedzialu.
    __host__ __device__  interval(float a, float b) : min(a), max(b) {}

    //! @brief oblicza rozmiar zdefiniowanego przedzialu.
    __host__ __device__  float size() const {
        return max - min;
    }

    //! @brief Sprawdza czy dany punkt znajduje sie w (DOMKNIETYM) przedziale
    __host__ __device__  bool contains(float x) const {
        return min <= x && x <= max;
    }

    //! @brief Sprawdza czy dany punkt znajduje sie w (OTWARTYM) przedziale
    __host__ __device__  bool surrounds(float x) const {
        return min < x && x < max;
    }

    //! @brief Sprawdza czy dany punkt znajduje sie w przedziale, jezeli nie to w przypadku przekroczenia przedzialu
    //! zwraca wartosc min lub max.
    __host__ __device__ float clamp(float x) const;

    //! @brief Definicja przedzialu jako pustego
    static const interval empty;
    //! @brief Definicja przedzialu jako nieskonczonego
    static const interval universe;
};

#endif