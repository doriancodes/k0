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

.globl gdt_flush
.type gdt_flush, @function


# ---------------------------------------------------
# GDT flush function — called from C to load the IDT
# void gdt_flush(uint32_t *gdt_ptr);
# ---------------------------------------------------

gdt_flush:
    movl 4(%esp), %eax       # Get pointer to GDT
    lgdt (%eax)              # Load GDT

    movw $0x10, %ax          # 0x10 = GDT data segment selector
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs
    movw %ax, %ss

    ljmp $0x08, $flush       # Far jump to reload CS (0x08 = code segment)

flush:
    ret

# ---------------------------------------------------
# IDT flush function — called from C to load the IDT
# void idt_flush(uint32_t *idt_ptr);
# ---------------------------------------------------

.global idt_flush
.type idt_flush, @function
idt_flush:
   movl 4(%esp), %eax       # Get pointer to IDT (first argument)
   lidt (%eax)              # Load IDT using value at address
   ret

#isr
.macro ISR_NOERRCODE num
    .globl isr\num
    .type isr\num, @function
isr\num:
    cli
    pushl $0             # Fake error code
    pushl $\num          # Interrupt number
    jmp isr_common_stub
.endm

# .macro ISR_ERRCODE num
#     .globl isr\num
#     .type isr\num, @function
# isr\num:
#     cli
#     xchgl (%esp), %eax     # Swap top of stack (err_code from CPU) with %eax
#     pushl $\num            # Push interrupt number
#     pushl %eax             # Push error code back
#     jmp isr_common_stub
# .endm

.macro ISR_ERRCODE num
    .globl isr\num
    .type isr\num, @function
isr\num:
    cli
    pushl $\num          # Push real error code already on stack, add ISR number
    jmp isr_common_stub
.endm

.irp n, 0,1,2,3,4,5,6,7,9,15,16,18,19,20,21,22,23,24,25,26,27,28,29,30,31
    ISR_NOERRCODE \n
.endr

ISR_ERRCODE 8     # Double fault
ISR_ERRCODE 10    # Invalid TSS
ISR_ERRCODE 11    # Segment not present
ISR_ERRCODE 12    # Stack-segment fault
# ISR_ERRCODE 13    # General protection fault
.globl isr13
.type isr13, @function
isr13:
    jmp exc_0d_handler

ISR_ERRCODE 14    # Page fault
ISR_ERRCODE 17    # Alignment check

.extern isr_handler
.globl isr_common_stub
.type isr_common_stub, @function

isr_common_stub:
    pusha                       # Push general-purpose registers

    movw %ds, %ax
    pushl %eax                  # Save current data segment selector

    movw $0x10, %ax             # Load kernel data segment selector
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs

    call isr_handler            # Call C handler

    popl %eax                   # Restore original segment selector
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs

    popa                        # Restore general-purpose registers

    addl $8, %esp               # Clean up pushed error code and ISR #
    iret
    
    
.macro IRQ num
    .globl irq\num
    .type irq\num, @function
irq\num:
    cli
    pushl $0
    pushl $(32 + \num)
    jmp irq_common_stub
.endm

.irp n, 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
    IRQ \n
.endr

.extern irq_handler
.global irq_common_stub
.type irq_common_stub, @function

irq_common_stub:
    pusha                          # Push general-purpose registers

    movw %ds, %ax
    pushl %eax                     # Save original data segment selector

    movw $0x10, %ax                # Load kernel data segment
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs

    call irq_handler               # Call C IRQ handler

    popl %ebx                      # Restore original segment selector
    movw %bx, %ds
    movw %bx, %es
    movw %bx, %fs
    movw %bx, %gs

    popa                           # Restore registers
    addl $8, %esp                  # Skip error code and interrupt number
    iret

# .globl exc_0d_handler
# .type exc_0d_handler, @function
# exc_0d_handler:
#     pushw %gs
#     movw $0x10, %ax         # Kernel data segment (adjust if needed)
#     movw %ax, %gs

#     movw $'D', %ax
#     movw %ax, %gs:0xb8000

#     pusha
#     pushw %ds
#     pushw %es

#     movw $0x10, %ax
#     movw %ax, %ds
#     movw %ax, %es

#     call gpfExcHandler      # You must define this in C!

#     popw %es
#     popw %ds
#     popa

#     movl $0x2d442020, %eax  # '  D-' in ASCII: space, space, 'D', '-'
#     movl %eax, %gs:0xb8000

#     popw %gs
#     iret

.globl exc_0d_handler
.type exc_0d_handler, @function
exc_0d_handler:
    pusha
    call gpfExcHandler
    popa
    iret
