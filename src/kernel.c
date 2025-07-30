#include "idt.h"

// --- Entry point ---
void kernel_main(void) {
  idt_init();

  for (;;) {
    __asm__("hlt");
  }
}
