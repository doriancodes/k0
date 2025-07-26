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
      vidmem[pos + 1] = *str % 16; // 0x07 if gray
      col++;
    }
  }
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
  kprint("Hello, world!\n");
  kprint("Welcome to Kerny OS!\n");
  while (1) {
  }
}
