#ifndef MATH_HPP
#define MATH_HPP

#include <cmath>
#include <cstring>

struct Vector2 {
    float x, y;
};

struct Vector3 {
    float x, y, z;
};

struct Vector4 {
    float x, y, z, w;
};

// Funciones matemáticas portadas y adaptadas
// Ported and adapted math functions

void InitTrigTable(float* table, int size);
void CalculateVector(float* output, float* input1, float* input2, float* input3, float* input4);
unsigned int ColorToUInt(float* color);

#endif // MATH_HPP
