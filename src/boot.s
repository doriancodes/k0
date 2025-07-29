# boot.s — AT&T syntax version
.section .multiboot
    .long 0x1BADB002
    .long 3
    .long -(0x1BADB002 + 3)

.section .text
.global _start
.type _start, @function
_start:
    cli
    movl $kernel_main, %eax
    call *%eax

.hang:
    hlt
    jmp .hang
