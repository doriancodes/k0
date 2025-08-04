//
// isr.c -- High level interrupt service routines and interrupt request
// handlers. Part of this code is modified from Bran's kernel development
// tutorials. Rewritten for JamesM's kernel development tutorials.
//

#include "common.h"
#include "error.h"
#include "isr.h"
#include "monitor.h"
#include "serial.h"

void log_handler(registers_t regs) {

  serial_write("INTERRUPT: ");
  serial_write_dec(regs.int_no);
  serial_write("\n");

  serial_write("EIP: 0x");
  serial_write_hex(regs.eip);
  serial_write("\n");
  serial_write("ESP: 0x");
  serial_write_hex(regs.esp);
  serial_write("\n");
  serial_write("EBP: 0x");
  serial_write_hex(regs.ebp);
  serial_write("\n");

  serial_write("EAX: 0x");
  serial_write_hex(regs.eax);
  serial_write(" EBX: 0x");
  serial_write_hex(regs.ebx);
  serial_write(" ECX: 0x");
  serial_write_hex(regs.ecx);
  serial_write(" EDX: 0x");
  serial_write_hex(regs.edx);
  serial_write("\n");

  serial_write("ERR CODE: 0x");
  serial_write_hex(regs.err_code);
  serial_write("\n");
}
// // This gets called from our ASM interrupt handler stub.
// void isr_handler(registers_t *regs) {

//   serial_write("INTERRUPT: ");
//   serial_write_dec(regs->int_no);
//   serial_write("\n");

//   serial_write("EIP: 0x");
//   serial_write_hex(regs->eip);
//   serial_write("\n");
//   serial_write("ESP: 0x");
//   serial_write_hex(regs->esp);
//   serial_write("\n");
//   serial_write("EBP: 0x");
//   serial_write_hex(regs->ebp);
//   serial_write("\n");

//   serial_write("EAX: 0x");
//   serial_write_hex(regs->eax);
//   serial_write(" EBX: 0x");
//   serial_write_hex(regs->ebx);
//   serial_write(" ECX: 0x");
//   serial_write_hex(regs->ecx);
//   serial_write(" EDX: 0x");
//   serial_write_hex(regs->edx);
//   serial_write("\n");

//   serial_write("ERR CODE: 0x");
//   serial_write_hex(regs->err_code);
//   serial_write("\n");
//   monitor_write("recieved interrupt: ");
//   monitor_write_dec(regs->int_no);
//   monitor_put('\n');

//   // Call the handler manually for GPF
//   if (regs->int_no == 13) {
//     serial_write("→ Calling gpfExcHandler()\n");
//     gpfExcHandler(); // <<<<< THIS LINE IS NEEDED
//   }

//   // Optional: handle double fault specially too
//   if (regs->int_no == 8) {
//     monitor_write("→ DOUBLE FAULT!\n");
//     while (1)
//       asm volatile("hlt");
//   } // if (regs.int_no == 13) {
//   //   monitor_write("→ GPF triggered\n");
//   // }

//   // if (regs.int_no == 8) {
//   //   monitor_write("→ DOUBLE FAULT!\n");
//   // }

//   // while (1) {
//   //   asm volatile("hlt");
//   // }
// }

// This gets called from our ASM interrupt handler stub.
void isr_handler(registers_t regs) {
  log_handler(regs);
  monitor_write("recieved interrupt: ");
  monitor_write_dec(regs.int_no);
  monitor_put('\n');
}

isr_t interrupt_handlers[256];

void register_interrupt_handler(u8int n, isr_t handler) {
  interrupt_handlers[n] = handler;
}

// This gets called from our ASM interrupt handler stub.
void irq_handler(registers_t regs) {
  // Send an EOI (end of interrupt) signal to the PICs.
  // If this interrupt involved the slave.
  if (regs.int_no >= 40) {
    // Send reset signal to slave.
    outb(0xA0, 0x20);
  }
  // Send reset signal to master. (As well as slave, if necessary).
  outb(0x20, 0x20);

  if (interrupt_handlers[regs.int_no] != 0) {
    isr_t handler = interrupt_handlers[regs.int_no];
    handler(regs);
  }
}
