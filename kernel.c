void kernel_main(void) {
  const char *str = "Hello!";
  char *vidmem = (char *)0xb8000;
  for (int i = 0; str[i] != '\0'; i++) {
    vidmem[i * 2] = str[i];
    vidmem[i * 2 + 1] = 0x07; // Light grey on black
  }

  while (1) {
  }
}
