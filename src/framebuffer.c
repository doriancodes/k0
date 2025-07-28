#include "framebuffer.h"
#include "limine.h"
#include <stdint.h>

framebuffer_t fb;

extern struct limine_framebuffer_request framebuffer_request;

void framebuffer_init(void) {
  if (framebuffer_request.response == NULL ||
      framebuffer_request.response->framebuffer_count < 1) {
    for (;;)
      __asm__("hlt");
  }

  struct limine_framebuffer *lfb =
      framebuffer_request.response->framebuffers[0];
  fb.addr = lfb->address;
  fb.width = lfb->width;
  fb.height = lfb->height;
  fb.pitch = lfb->pitch / 4;
  fb.bpp = lfb->bpp;
}

void framebuffer_clear(uint32_t color) {
  for (uint64_t y = 0; y < fb.height; y++) {
    for (uint64_t x = 0; x < fb.width; x++) {
      fb.addr[y * fb.pitch + x] = color;
    }
  }
}

void framebuffer_draw_rect(uint64_t x, uint64_t y, uint64_t w, uint64_t h,
                           uint32_t color) {
  for (uint64_t yy = y; yy < y + h; yy++) {
    for (uint64_t xx = x; xx < x + w; xx++) {
      if (xx >= fb.width || yy >= fb.height)
        continue;
      fb.addr[yy * fb.pitch + xx] = color;
    }
  }
}
