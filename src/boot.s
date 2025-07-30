.section .multiboot
    .long 0x1BADB002          # magic
    .long 0x0                 # flags
    .long -(0x1BADB002 + 0x0) # checksum

.section .text
.global _start
.type _start, @function
_start:
    cli                       # Disable interrupts

    # Load GDT
    lgdt gdt_descriptor

    # Set PE bit in CR0 (protected mode)
    movl %cr0, %eax
    orl $1, %eax
    movl %eax, %cr0

    # Far jump to flush prefetch and load CS
    ljmp $0x08, $protected_mode_entry

# --- GDT Entries ---
.align 8
gdt:
    .quad 0x0000000000000000       # null descriptor
    .quad 0x00CF9A000000FFFF       # code segment: base=0, limit=4GB
    .quad 0x00CF92000000FFFF       # data segment: base=0, limit=4GB

gdt_descriptor:
    .word gdt_end - gdt - 1        # size
    .long gdt                      # base

gdt_end:

# --- Protected Mode Entry ---
protected_mode_entry:
    # Load segment registers
    mov $0x10, %ax                 # data segment selector
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss

    # Jump to kernel main
    call kernel_main

.hang:
    hlt
    jmp .hang

