# liblinht-ctrl Makefile

# Overrideable variables for Yocto compatibility
CC ?= gcc
CFLAGS ?= -Wall -Wextra -O2 -fPIC -Iinclude
LDFLAGS ?= -lgpiod
PREFIX ?= /usr

# Library files
LIB_NAME = liblinht-ctrl
STATIC_LIB = $(LIB_NAME).a
SHARED_LIB = $(LIB_NAME).so

# Source files
SOURCES = src/gpio.c src/pwm.c src/backlight.c
OBJECTS = $(SOURCES:.c=.o)
HEADERS = include/liblinht-ctrl.h

# Default target
all: $(STATIC_LIB) $(SHARED_LIB)

# Static library
$(STATIC_LIB): $(OBJECTS)
	ar rcs $@ $^

# Shared library
$(SHARED_LIB): $(OBJECTS)
	$(CC) -shared -o $@ $^ $(LDFLAGS)

# Object files
%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

# Clean build artifacts
clean:
	rm -f $(OBJECTS) $(STATIC_LIB) $(SHARED_LIB) example

# Install headers and libraries (optimized for Yocto and standalone)
install: $(STATIC_LIB) $(SHARED_LIB)
	mkdir -p $(DESTDIR)$(PREFIX)/include/
	mkdir -p $(DESTDIR)$(PREFIX)/lib/
	cp $(HEADERS) $(DESTDIR)$(PREFIX)/include/
	cp $(STATIC_LIB) $(SHARED_LIB) $(DESTDIR)$(PREFIX)/lib/
ifndef DESTDIR
	ldconfig
endif

# Uninstall (adjusted for prefix)
uninstall:
	rm -f $(DESTDIR)$(PREFIX)/include/liblinht-ctrl.h
	rm -f $(DESTDIR)$(PREFIX)/lib/$(STATIC_LIB) $(DESTDIR)$(PREFIX)/lib/$(SHARED_LIB)
ifndef DESTDIR
	ldconfig
endif

# Example program
example: example.c $(STATIC_LIB)
	$(CC) $(CFLAGS) -o $@ $< -L. -llinht-ctrl $(LDFLAGS)

.PHONY: all clean install uninstall example
