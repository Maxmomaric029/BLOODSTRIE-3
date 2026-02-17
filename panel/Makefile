# Makefile para Bloodstrike iOS Mod Menu
# Desarrollado para compatibilidad máxima con GitHub Actions

SYSROOT  = $(shell xcrun --sdk iphoneos --show-sdk-path)
ARCH     = arm64

# Binarios directos del toolchain (evita el wrapper xcrun que pierde flags en CI)
CC      = $(shell xcrun --sdk iphoneos --find clang)
CXX     = $(shell xcrun --sdk iphoneos --find clang++)

# Flags comunes de compilación
COMMON_FLAGS = \
    -isysroot $(SYSROOT) \
    -arch $(ARCH) \
    -fobjc-arc \
    -O2 \
    -Wall \
    -Wno-deprecated-declarations

# Flags de enlace — TODOS los flags van aquí explícitamente
# para que el binario directo de clang++ los reciba sin pasar por xcrun
LDFLAGS = \
    -isysroot $(SYSROOT) \
    -arch $(ARCH) \
    -dynamiclib \
    -undefined dynamic_lookup \
    -framework Foundation \
    -framework UIKit \
    -stdlib=libc++ \
    -lc++

all: ModMenu.dylib

ModMenu.dylib: ModMenu.o Math.o
	$(CXX) $(LDFLAGS) -o $@ $^

ModMenu.o: ModMenu.mm
	$(CC) $(COMMON_FLAGS) -c $< -o $@

Math.o: Math.cpp
	$(CXX) $(COMMON_FLAGS) -std=c++17 -c $< -o $@

clean:
	rm -f *.o ModMenu.dylib
