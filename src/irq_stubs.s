.section .text
.global irq0, irq1, irq2, irq3, irq4, irq5, irq6, irq7
.global irq8, irq9, irq10, irq11, irq12, irq13, irq14, irq15
.global irq_common_stub

.extern irq_handler

.macro DEFINE_IRQ num
irq\num:
    cli
    pushl $0            # Dummy error code (IRQs don't have one)
    pushl $(32 + \num)  # IRQ number (remapped)
    jmp irq_common_stub
.endm

DEFINE_IRQ 0
DEFINE_IRQ 1
DEFINE_IRQ 2
DEFINE_IRQ 3
DEFINE_IRQ 4
DEFINE_IRQ 5
DEFINE_IRQ 6
DEFINE_IRQ 7
DEFINE_IRQ 8
DEFINE_IRQ 9
DEFINE_IRQ 10
DEFINE_IRQ 11
DEFINE_IRQ 12
DEFINE_IRQ 13
DEFINE_IRQ 14
DEFINE_IRQ 15

irq_common_stub:
    pusha
    call irq_handler
    popa
    add $8, %esp        # Pop dummy error + IRQ number
    iret

