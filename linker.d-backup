ENTRY(_start)

SECTIONS {
  . = 0xffffffff80000000;  /* Higher-half kernel base */

  .text : {
    *(.text*)
  }

  .rodata : {
    *(.rodata*)
  }

  .data : {
    *(.data*)
  }

  .bss : {
    *(.bss*)
    *(COMMON)
  }
}

