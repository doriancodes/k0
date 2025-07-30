#include "vga.h"

// --- Entry point ---
void kernel_main(void) {
  vga_init();
  vga_puts("Hello from VGA text mode!\n");
  vga_puts("This is your kernel speaking\n");

  for (;;) {
    __asm__("hlt");
  }
}
