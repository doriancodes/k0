#ifndef K0_FRAMEBUFFER_H
#define K0_FRAMEBUFFER_H

#include <stddef.h>
#include <stdint.h>

typedef struct {
  uint32_t *addr;
  uint64_t width;
  uint64_t height;
  uint64_t pitch;
  uint64_t bpp;
} framebuffer_t;

extern framebuffer_t fb;

void framebuffer_init(void);
void framebuffer_clear(uint32_t color);
void framebuffer_draw_rect(uint64_t x, uint64_t y, uint64_t w, uint64_t h,
                           uint32_t color);

#endif
