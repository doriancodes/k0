#pragma once
#include <stdint.h>

void vga_init(void);
void vga_clear(void);
void vga_putc(char c);
void vga_puts(const char *str);
