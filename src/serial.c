
#include "common.h"
#include "serial.h"

#define SERIAL_PORT 0x3F8

void serial_init() {
  outb(SERIAL_PORT + 1, 0x00);
  outb(SERIAL_PORT + 3, 0x80);
  outb(SERIAL_PORT + 0, 0x03); // 38400 baud
  outb(SERIAL_PORT + 1, 0x00);
  outb(SERIAL_PORT + 3, 0x03); // 8N1
  outb(SERIAL_PORT + 2, 0xC7); // FIFO
  outb(SERIAL_PORT + 4, 0x0B); // IRQs on, RTS/DSR set
}

int serial_is_transmit_empty() { return inb(SERIAL_PORT + 5) & 0x20; }

void serial_write_char(char c) {
  while (!serial_is_transmit_empty())
    ;
  outb(SERIAL_PORT, c);
}

void serial_write(const char *str) {
  while (*str)
    serial_write_char(*str++);
}

void serial_write_dec(unsigned int n) {
  char buf[12]; // enough for 32-bit integer
  int i = 0;

  if (n == 0) {
    serial_write_char('0');
    return;
  }

  while (n > 0) {
    buf[i++] = '0' + (n % 10);
    n /= 10;
  }

  // print in reverse
  while (--i >= 0)
    serial_write_char(buf[i]);
}

void serial_write_hex(unsigned int n) {
  // serial_write("0x");
  char hex[] = "0123456789ABCDEF";
  for (int i = 28; i >= 0; i -= 4)
    serial_write_char(hex[(n >> i) & 0xF]);
}
