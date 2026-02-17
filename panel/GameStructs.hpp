#ifndef GAME_STRUCTS_HPP
#define GAME_STRUCTS_HPP

#include <cstdint>

// Offsets base (Messiah Engine) - Bloodstrike
#define adrObjects 0x39C8B98
#define adrD3D11Device 0x39B8DA8
#define D3D11Device_CameraInfo 0x80
#define ptrObject1 0x38
#define ptrObject2 0x470

// Offsets extraídos de offsets2.txt
#define OFF_CurrentMatch 0x50
#define OFF_LocalPlayer 0x44
#define OFF_DictionaryEntities 0x68
#define OFF_Player_IsDead 0x4c
#define OFF_Player_Name 0x24c
#define OFF_AvatarManager 0x420
#define OFF_Avatar 0x18
#define OFF_Avatar_Data 0x10

// Silent Aim (AimKill) Offsets
#define OFF_sAim1 0x4a0 // isShooting (bool)
#define OFF_sAim2 0x874 // weaponData (uintptr_t)
#define OFF_sAim3 0x38  // startPos (Vec3)
#define OFF_sAim4 0x2c  // aimPosition (Vec3 - Destination)

struct Vec3 {
    float x, y, z;
    Vec3 operator+(const Vec3& v) const { return {x + v.x, y + v.y, z + v.z}; }
    Vec3 operator-(const Vec3& v) const { return {x - v.x, y - v.y, z - v.z}; }
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

class Entity {
public:
    char pad_0000[0x4c];
    bool IsDead; // 0x4c
    char pad_004d[3];
    Vec3 Origin; // 0x50
};

#endif
