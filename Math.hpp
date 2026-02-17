#ifndef MATH_HPP
#define MATH_HPP

#include <cmath>

struct Vector2 {
    float x, y;
};

struct Vector3 {
    float x, y, z;
};

// Declaración de las funciones portadas
void CalculateVector(float* output, float* input1, float* input2, float* input3, float* input4);
unsigned int ColorToUInt(float* color);

#endif
