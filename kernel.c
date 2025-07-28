#include "limine.h"
#include <stddef.h>
#include <stdint.h>

// --- Framebuffer request ---
static volatile struct limine_framebuffer_request framebuffer_request = {
    .id = LIMINE_FRAMEBUFFER_REQUEST, .revision = 0};

// --- Entry point ---
void _start(void) {
  if (framebuffer_request.response == NULL ||
      framebuffer_request.response->framebuffer_count < 1) {
    for (;;) {
      __asm__("hlt");
    }
  }

  struct limine_framebuffer *fb = framebuffer_request.response->framebuffers[0];
  uint32_t *framebuffer = (uint32_t *)fb->address;
  uint64_t width = fb->width;
  uint64_t height = fb->height;
  uint64_t pitch = fb->pitch / 4;

  // Clear screen to black
  for (uint64_t y = 0; y < height; y++) {
    for (uint64_t x = 0; x < width; x++) {
      framebuffer[y * pitch + x] = 0x000000; // black
    }
  }

  // Draw a red square
  for (uint64_t y = 50; y < 150; y++) {
    for (uint64_t x = 50; x < 200; x++) {
      framebuffer[y * pitch + x] = 0x0000FF; // red (BGR)
    }
  }

  for (;;) {
    __asm__("hlt");
  }
}
