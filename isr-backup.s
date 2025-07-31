.global isr0

isr0:
    cli
    pusha
    call isr_handler
    popa
    iret

