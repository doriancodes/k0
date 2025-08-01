// main.c -- Defines the C-code kernel entry point, calls initialisation
// routines. Made for JamesM's tutorials
#include "descriptor_tables.h"
#include "monitor.h"

int kernel_main(struct multiboot *mboot_ptr) {
  init_descriptor_tables();
  // All our initialisation calls will go in here.
  monitor_clear();
  monitor_write("Hello, world!");
  asm volatile("int $0x3");
  asm volatile("int $0x4");
  while (1) {
    asm volatile("hlt");
  }
}
