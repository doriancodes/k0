#pragma once
#include <stdint.h>

struct idt_entry {
  uint16_t offset_low;
  uint16_t selector;
  uint8_t zero;
  uint8_t type_attr;
  uint16_t offset_high;
} __attribute__((packed));

struct idt_ptr {
  uint16_t limit;
  uint32_t base;
} __attribute__((packed));

// Setup IDT
void idt_init(void);

// Called from ISR stubs
void isr_handler(void);

void idt_set_gate(int num, uint32_t base, uint16_t sel, uint8_t flags);
