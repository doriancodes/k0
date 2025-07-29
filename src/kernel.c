#include <stddef.h>
#include <stdint.h>

// --- Entry point ---
void kernel_main(void) {
  for (;;) {
    __asm__("hlt");
  }
}
