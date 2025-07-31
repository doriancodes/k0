# src/isr.s — ISRs 0–31 (CPU exceptions)
.intel_syntax noprefix
.global isr_common_stub
.extern isr_handler

.macro ISR_NOERR num
.global isr\num
isr\num:
    cli
    push 0               # Push dummy error code
    push \num            # Push interrupt number
    jmp isr_common_stub
.endm

.macro ISR_ERR num
.global isr\num
isr\num:
    cli
    push \num            # Push interrupt number
    jmp isr_common_stub
.endm

# CPU exceptions without error codes
ISR_NOERR 0
ISR_NOERR 1
ISR_NOERR 2
ISR_NOERR 3
ISR_NOERR 4
ISR_NOERR 5
ISR_NOERR 6
ISR_NOERR 7
ISR_NOERR 9
ISR_NOERR 15

# CPU exceptions with error codes
ISR_ERR 8
ISR_ERR 10
ISR_ERR 11
ISR_ERR 12
ISR_ERR 13
ISR_ERR 14
ISR_ERR 16
ISR_ERR 17
ISR_ERR 18
ISR_ERR 19
ISR_ERR 20
ISR_ERR 21
ISR_ERR 22
ISR_ERR 23
ISR_ERR 24
ISR_ERR 25
ISR_ERR 26
ISR_ERR 27
ISR_ERR 28
ISR_ERR 29
ISR_ERR 30
ISR_ERR 31

# --- Common handler ---
isr_common_stub:
    pusha
    call isr_handler
    popa
    add esp, 8       # Pop error code + interrupt number
    iret

