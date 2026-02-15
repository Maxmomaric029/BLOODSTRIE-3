#ifndef GAME_STRUCTS_HPP
#define GAME_STRUCTS_HPP

#include <cstdint>

// Offsets base (Messiah Engine)
#define adrObjects 0x39C8B98
#define adrD3D11Device 0x39B8DA8
#define D3D11Device_CameraInfo 0x80
#define ptrObject1 0x38
#define ptrObject2 0x470

struct Vec3 {
    float x, y, z;
};

struct Matrix4x4 {
    float m[4][4];
};

class CameraInfo {
public:
    char pad_0000[0x10]; // 0x0000
    Vec3 CamPos;         // 0x0010 
    char pad_001C[0x4];  // 0x001C
    Matrix4x4 Proj;      // 0x0020 
    Matrix4x4 View;      // 0x0060 
    Matrix4x4 ViewProj;  // 0x00A0 
};

struct GameVector {
    uintptr_t Begin;
    uintptr_t Cur;
    uintptr_t End;
};

// Estructuras de Entidad adaptadas
class Entity {
public:
    // Basado en el dump del motor Messiah
    char pad_0000[0x50];
    Vec3 Origin; // 0x0050 (Ajustado según Entity struct)
    // Otros campos necesarios...
};

#endif // GAME_STRUCTS_HPP
