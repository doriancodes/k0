#include "vga.h"

#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_MEMORY (uint16_t *)0xB8000

static uint16_t *vga_buffer = VGA_MEMORY;
static uint8_t vga_color = 0x0F; // Light gray on black
static uint16_t cursor_row = 0;
static uint16_t cursor_col = 0;

static uint16_t make_vga_entry(char c, uint8_t color) {
  return (uint16_t)c | ((uint16_t)color << 8);
}

void vga_init(void) { vga_clear(); }

void vga_clear(void) {
  for (uint16_t y = 0; y < VGA_HEIGHT; y++) {
    for (uint16_t x = 0; x < VGA_WIDTH; x++) {
      vga_buffer[y * VGA_WIDTH + x] = make_vga_entry(' ', vga_color);
    }
  }
  cursor_row = 0;
  cursor_col = 0;
}

void vga_putc(char c) {
  if (c == '\n') {
    cursor_col = 0;
    if (++cursor_row == VGA_HEIGHT)
      cursor_row = 0;
    return;
  }

  vga_buffer[cursor_row * VGA_WIDTH + cursor_col] =
      make_vga_entry(c, vga_color);
  if (++cursor_col == VGA_WIDTH) {
    cursor_col = 0;
    if (++cursor_row == VGA_HEIGHT)
      cursor_row = 0;
  }
}

void vga_puts(const char *str) {
  while (*str) {
    vga_putc(*str++);
  }
}

void vga_puthex(uint32_t num) {
  char hex[] = "0123456789ABCDEF";
  vga_puts("0x");
  for (int i = 28; i >= 0; i -= 4) {
    vga_putc(hex[(num >> i) & 0xF]);
  }
}
