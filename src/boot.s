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
ISR_ERRCODE 13    # General protection fault
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
    sti
    iret

