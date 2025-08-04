
#include "monitor.h"
#include "serial.h"

int nestexc = 0;
#define MAX_NESTED_EXCEPTIONS 3

void gpfExcHandler(void) {
  // if (nestexc > MAX_NESTED_EXCEPTIONS) {
  //   serial_write("Too many nested exceptions!\n");
  //   monitor_write("→ PANIC: too many nested exceptions\n");
  //   while (1)
  //     asm volatile("hlt");
  // }

  // nestexc++;

  // serial_write("→ GPF HANDLER CALLED\n");
  // monitor_write("→ General Protection Fault handled\n");

  // // In a real OS, you'd attempt to clean up or recover here.
  // // For now, just log and return.

  // nestexc--;
  static int count = 0;
  count++;

  // Do nothing else
  if (count > 3) {
    while (1)
      asm volatile("hlt");
  }
}
