# Makefile para Bloodstrike iOS Mod Menu
# Desarrollado para compatibilidad máxima con GitHub Actions

SYSROOT = $(shell xcrun --sdk iphoneos --show-sdk-path)
ARCH = arm64

# Compiladores
CC = xcrun --sdk iphoneos clang
CXX = xcrun --sdk iphoneos clang++

# Flags comunes
COMMON_FLAGS = -isysroot $(SYSROOT) -arch $(ARCH) -fobjc-arc -O2 -Wall

# Flags de enlace (Linking)
LDFLAGS = $(COMMON_FLAGS) -dynamiclib -undefined dynamic_lookup -framework Foundation -framework UIKit -lc++

all: ModMenu.dylib

ModMenu.dylib: ModMenu.o Math.o
	$(CXX) $(LDFLAGS) -o ModMenu.dylib ModMenu.o Math.o

ModMenu.o: ModMenu.mm
	$(CC) $(COMMON_FLAGS) -c ModMenu.mm -o ModMenu.o

Math.o: Math.cpp
	$(CXX) $(COMMON_FLAGS) -c Math.cpp -o Math.o

clean:
	rm -f *.o ModMenu.dylib
