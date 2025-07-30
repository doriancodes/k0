# TODO

1. VGA text mode      → DONE
2. Kprint abstraction → A proper kprintf or logging function -> DONE
3. VGA scrolling      → Improve UX and debugging  --> DONE
4. Framebuffer init   → Get pixels, maybe via VBE or UEFI GOP
5. Terminal layer     → Write text into framebuffer
6. Windowing system   → Later, after multitasking and memory mgmt


 - GDT (done)

 - Switch to protected mode (done)

 - Call kernel C function (done)

 - VGA text mode output (putchar, puts, etc.) (done)

 - IDT + ISRs (division by zero handler, etc.) (done)

 - IRQs + timer + keyboard

 - Basic memory management (paging, malloc-like allocator)

 - Optional: Framebuffer for graphics

 - Filesystem support (read files from initrd or ATA)

 - User-space and syscalls (microkernel-style)
