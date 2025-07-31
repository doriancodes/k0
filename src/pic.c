#include <stdint.h>

#define PIC1_COMMAND 0x20
#define PIC1_DATA 0x21
#define PIC2_COMMAND 0xA0
#define PIC2_DATA 0xA1

#define PIC_EOI 0x20

// Send a byte to a port
static inline void outb(uint16_t port, uint8_t value) {
  asm volatile("outb %0, %1" : : "a"(value), "Nd"(port));
}

// Read a byte from a port
static inline uint8_t inb(uint16_t port) {
  uint8_t ret;
  asm volatile("inb %1, %0" : "=a"(ret) : "Nd"(port));
  return ret;
}

// Remap IRQs to IDT entries 32–47
void pic_remap(void) {
  // Save current masks
  uint8_t a1 = inb(PIC1_DATA);
  uint8_t a2 = inb(PIC2_DATA);

  // Start init
  outb(PIC1_COMMAND, 0x11);
  outb(PIC2_COMMAND, 0x11);

  // Set vector offsets
  outb(PIC1_DATA, 0x20); // IRQ0–7 to 0x20–0x27
  outb(PIC2_DATA, 0x28); // IRQ8–15 to 0x28–0x2F

  // Setup cascading
  outb(PIC1_DATA, 0x04);
  outb(PIC2_DATA, 0x02);

  // Set 8086 mode
  outb(PIC1_DATA, 0x01);
  outb(PIC2_DATA, 0x01);

  // Restore saved masks
  outb(PIC1_DATA, a1);
  outb(PIC2_DATA, a2);
}

// Send End of Interrupt
void pic_send_eoi(int irq) {
  if (irq >= 8)
    outb(PIC2_COMMAND, PIC_EOI);
  outb(PIC1_COMMAND, PIC_EOI);
}
