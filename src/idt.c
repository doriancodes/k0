
#include "idt.h"
#include "isr.h"
#include <stddef.h>

#define IDT_ENTRIES 256
static struct idt_entry idt[IDT_ENTRIES];
static struct idt_ptr idtp;

extern void isr0(); // From isr.s

static void idt_set_gate(int num, uint32_t base, uint16_t sel, uint8_t flags) {
  idt[num].offset_low = base & 0xFFFF;
  idt[num].selector = sel;
  idt[num].zero = 0;
  idt[num].type_attr = flags;
  idt[num].offset_high = (base >> 16) & 0xFFFF;
}

void idt_init(void) {
  idtp.limit = sizeof(idt) - 1;
  idtp.base = (uint32_t)&idt;

  idt_set_gate(0, (uint32_t)isr0, 0x08,
               0x8E); // Present, ring 0, 32-bit interrupt gate

  // Load IDT
  asm volatile("lidtl (%0)" : : "r"(&idtp));
}

// Very simple ISR handler
void isr_handler(void) {
  // For now, do nothing. Later, print message or halt.
  asm volatile("cli; hlt");
}
