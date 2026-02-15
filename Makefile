TARGET = ModMenu
ARCHS = arm64
SYSROOT = $(shell xcrun --sdk iphoneos --show-sdk-path)
CC = $(shell xcrun --sdk iphoneos --find clang)
CXX = $(shell xcrun --sdk iphoneos --find clang++)

CFLAGS = -isysroot $(SYSROOT) -arch $(ARCHS) -fobjc-arc -O2 -Wall
LDFLAGS = -dynamiclib -undefined dynamic_lookup -framework Foundation -framework UIKit

SOURCES = ModMenu.mm Math.cpp
OBJECTS = $(SOURCES:.mm=.o)
OBJECTS := $(OBJECTS:.cpp=.o)

all: $(TARGET).dylib

$(TARGET).dylib: $(OBJECTS)
	$(CXX) $(LDFLAGS) -o $@ $^

%.o: %.mm
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.cpp
	$(CXX) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJECTS) $(TARGET).dylib
