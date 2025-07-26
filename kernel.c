#include <stdarg.h>

void itoa(int value, char *str, int base) {
  char *digits = "0123456789ABCDEF";
  char buffer[32];
  int i = 0;
  int is_negative = 0;

  if (value == 0) {
    str[0] = '0';
    str[1] = '\n';
    return;
  }

  if (value < 0 && base == 10) {
    is_negative = 1;
    value = -value;
  }

  while (value > 0) {
    buffer[i++] = digits[value % base];
    value /= base;
  }

  if (is_negative)
    buffer[i++] = '-';

  for (int j = 0; j < i; j++) {
    str[j] = buffer[i - j - 1];
  }

  str[i] = '\0';
}

void kprint(const char *str) {
  volatile char *vidmem = (char *)0xb8000;
  static int row = 0, col = 0;

  while (*str) {
    if (*str == '\n') {
      row++;
      col = 0;
      str++;
    } else {
      int pos = (row * 80 + col) * 2;
      vidmem[pos] = *str++;
      vidmem[pos + 1] = 0x07;
      col++;
    }
  }
}

void kprintf(const char *fmt, ...) {
  va_list args;
  va_start(args, fmt);

  char buffer[32];
  for (int i = 0; fmt[i] != '\0'; i++) {
    if (fmt[i] == '%' && fmt[i + 1]) {
      i++;
      switch (fmt[i]) {
      case 's': {
        const char *str = va_arg(args, const char *);
        kprint(str);
        break;
      }
      case 'd': {
        int val = va_arg(args, int);
        itoa(val, buffer, 10);
        kprint(buffer);
        break;
      }
      case 'x': {
        int val = va_arg(args, int);
        itoa(val, buffer, 16);
        kprint("0x");
        kprint(buffer);
      }
      default:
        kprint("%");
        char ch[2] = {fmt[i], 0};
        kprint(ch);
      }
    } else {
      char ch[2] = {fmt[i], 0};
      kprint(ch);
    }
  }

  va_end(args);
}

void clear_screen() {
  volatile char *vidmem = (char *)0xb8000;
  for (int i = 0; i < 80 * 25; i++) {
    vidmem[i * 2] = ' ';
    vidmem[i * 2 + 1] = 0x07;
  }
}

void kernel_main(void) {
  clear_screen();

  kprintf("Hello, %s!\n", "Kerny");
  kprintf("The answer is %d\n", 42);
  kprintf("Hex test: %x\n", 48879);

  while (1) {
  }
}
