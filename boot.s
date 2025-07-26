.section .multiboot
.align 4

.long 0x1BADB002 # magic number
.long 0x00000003 # flags (align + mem info)
.long -(0x1BADB002 + 0x00000003) # checksum = -(magic + flags)

.section .text
.globl _start
.type _start, @function

_start:
    call kernel_main
    cli
    hlt

