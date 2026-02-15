# Project Bloodstrike iOS Mod Menu

Este proyecto es un puerto del hack de PC a iOS, convertido en una biblioteca dinámica (`.dylib`) con un Mod Menu flotante.

## 🇪🇸 Documentación en Español

### Descripción
Este código implementa un "Mod Menu" básico para iOS. Incluye una interfaz gráfica (GUI) con botones flotantes y interruptores para activar funciones como Aimbot, ESP y God Mode.
También se han portado funciones matemáticas clave del código original en C (como cálculos vectoriales y tablas trigonométricas) a C++ limpio (`Math.cpp`).

### Estructura de Archivos
*   `ModMenu.mm`: El núcleo del hack. Contiene el código de la interfaz gráfica (Objective-C++) y el punto de entrada de la inyección.
*   `Math.cpp` / `Math.hpp`: Funciones matemáticas extraídas y adaptadas del código original.
*   `Makefile`: Script de compilación para generar el archivo `.dylib`.
*   `.github/workflows`: Configuración para compilar automáticamente en la nube con GitHub Actions.

### ⚠️ Advertencia Crítica sobre Offsets
El código original de PC (`.c`) contenía direcciones de memoria (offsets) específicas para la versión de Windows (x64). **Estos offsets NO funcionarán en iOS (ARM64).**
El juego en iOS es una compilación diferente. Debes actualizar los punteros en `ModMenu.mm` manualmente.
1.  Usa herramientas como **Frida** o **IDA Pro** en el binario descifrado de iOS (IPA).
2.  Busca las mismas funciones o estructuras.
3.  Actualiza las variables base en el código.

### Cómo Compilar
1.  **Opción A (GitHub Actions):** Simplemente sube este código a un repositorio de GitHub. La acción configurada compilará automáticamente el archivo `ModMenu.dylib` y lo podrás descargar desde la pestaña "Actions".
2.  **Opción B (Mac Local):**
    *   Asegúrate de tener Xcode instalado.
    *   Ejecuta el comando `make` en la terminal dentro de esta carpeta.

### Instalación en iPhone
1.  Necesitas un dispositivo con Jailbreak o una forma de inyectar dylibs (como Sideloadly o Esign).
2.  Inyecta `ModMenu.dylib` en el ejecutable del juego.

---

## 🇺🇸 English Summary

This is a port of the PC cheat logic to an iOS Dynamic Library with a GUI Mod Menu.
**Note:** The original memory offsets from the PC version are incompatible with iOS. You must reverse engineer the iOS binary to find the new addresses for functions like `GetEntityList` or `WorldToScreen`. The math functions have been ported to C++ in `Math.cpp`.
