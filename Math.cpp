#include "Math.hpp"

// Portación exacta de FUN_1400024c0 (Cálculos vectoriales complejos)
void CalculateVector(float* output, float* input1, float* input2, float* input3, float* input4) {
    float fVar1, fVar2, fVar3, fVar4, fVar5, fVar6, fVar7, fVar8, fVar9;
    float fVar10, fVar11, fVar12, fVar13, fVar14, fVar15, fVar16;

    fVar8 = input1[0];
    fVar9 = input1[1];
    fVar4 = input2[0];
    fVar16 = input4[0];
    fVar10 = fVar4 - fVar8;
    fVar1 = input4[1];
    fVar7 = input2[1];
    fVar12 = fVar7 - fVar9;
    fVar5 = (fVar1 - fVar9) * fVar12 + (fVar16 - fVar8) * fVar10;
    fVar11 = fVar8;
    fVar13 = fVar9;

    if ((0.0f <= fVar5) && (fVar2 = fVar12 * fVar12 + fVar10 * fVar10, fVar11 = fVar4, fVar13 = fVar7, fVar5 <= fVar2)) {
        fVar11 = (fVar10 * fVar5) / fVar2 + fVar8;
        fVar13 = (fVar12 * fVar5) / fVar2 + fVar9;
    }

    fVar5 = input3[0];
    fVar10 = input3[1];
    fVar14 = fVar5 - fVar4;
    fVar15 = fVar10 - fVar7;
    fVar3 = (fVar1 - fVar7) * fVar15 + (fVar16 - fVar4) * fVar14;
    fVar12 = fVar4;
    fVar2 = fVar7;

    if ((0.0f <= fVar3) && (fVar6 = fVar15 * fVar15 + fVar14 * fVar14, fVar12 = fVar5, fVar2 = fVar10, fVar3 <= fVar6)) {
        fVar12 = (fVar14 * fVar3) / fVar6 + fVar4;
        fVar2 = (fVar15 * fVar3) / fVar6 + fVar7;
    }

    fVar8 = fVar8 - fVar5;
    fVar9 = fVar9 - fVar10;
    fVar4 = (fVar1 - fVar10) * fVar9 + (fVar16 - fVar5) * fVar8;

    if (0.0f <= fVar4) {
        fVar7 = fVar9 * fVar9 + fVar8 * fVar8;
        if (fVar4 <= fVar7) {
            fVar5 = (fVar8 * fVar4) / fVar7 + fVar5;
            fVar10 = (fVar9 * fVar4) / fVar7 + fVar10;
        } else {
            fVar5 = input1[0];
            fVar10 = input1[1];
        }
    }

    fVar4 = (fVar1 - fVar2) * (fVar1 - fVar2) + (fVar16 - fVar12) * (fVar16 - fVar12);
    fVar9 = (fVar1 - fVar13) * (fVar1 - fVar13) + (fVar16 - fVar11) * (fVar16 - fVar11);
    fVar16 = (fVar1 - fVar10) * (fVar1 - fVar10) + (fVar16 - fVar5) * (fVar16 - fVar5);
    fVar8 = fVar4;

    if (fVar16 <= fVar4) {
        fVar8 = fVar16;
    }
    fVar16 = fVar9;
    if (fVar8 <= fVar9) {
        fVar16 = fVar8;
    }

    if (fVar16 == fVar9) {
        output[0] = fVar11;
        output[1] = fVar13;
    } else if (fVar16 == fVar4) {
        output[0] = fVar12;
        output[1] = fVar2;
    } else {
        output[0] = fVar5;
        output[1] = fVar10;
    }
}

// Portación de FUN_140002cc0 (Conversión de Color Float a UInt)
unsigned int ColorToUInt(float* color) {
    float r = color[0];
    float g = color[1];
    float b = color[2];
    float a = color[3];

    if (r < 0.0f) r = 0.0f; else if (r > 1.0f) r = 1.0f;
    if (g < 0.0f) g = 0.0f; else if (g > 1.0f) g = 1.0f;
    if (b < 0.0f) b = 0.0f; else if (b > 1.0f) b = 1.0f;
    if (a < 0.0f) a = 0.0f; else if (a > 1.0f) a = 1.0f;

    return (unsigned int)(a * 255.0f + 0.5f) << 24 |
           (unsigned int)(r * 255.0f + 0.5f) |
           (unsigned int)(g * 255.0f + 0.5f) << 8 |
           (unsigned int)(b * 255.0f + 0.5f) << 16;
}
