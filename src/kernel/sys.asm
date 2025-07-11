; SysCall implementation
.export sys_init,SYSCALL_TASK,SYSCALL_LOCK
.export sys_success,sys_error
.export apioff,apidptab,sparmtab

.import COP_ISR,COP_EXIT
.import UART_read,UART_write
.import CIO_open,CIO_close,CIO_read,CIO_write,CIO_dup
.import TASK_set_name

.include "kernel/api.inc"

.include "macros.inc"

.data
SYSCALL_TASK:   .res 2
SYSCALL_LOCK:   .res 2  ; two bytes, so we can use 16-bit STZ

apioff: .res 2  ; temporary store of api offset, used in stack cleanup

;
; System Call API dispatch table
; NOTE: update `maxapi` in api.inc after adding new item
;
apidptab:
        .addr UART_read
        .addr UART_write
        .addr CIO_open
        .addr CIO_close
        .addr CIO_read
        .addr CIO_write
        .addr CIO_dup
        .addr TASK_set_name

;
; System Call API parameters count
;
sparmtab:
        .word 4 ; UART_read
        .word 4 ; UART_write
        .word 4 ; CIO_open
        .word 2 ; CIO_close
        .word 2 ; CIO_read
        .word 2 ; CIO_write
        .word 4 ; CIO_dup
        .word 2 ; TASK_set_name

.code
.a16
.i16

sys_init:
        ; Set COP vector
        lda #COP_ISR
        sta $ffe4           ; Native COP vector

        stz SYSCALL_LOCK    ; We are not in a syscall

        rts

; Exit SysCall with return value in .A
sys_success:
.a16
        sta reg_a,s           ;overwrite .C’s stack copy
        ; Flag a successful operation by clearing the carry bit in SR:
        _a8
        lda reg_sr,s          ;stack copy of SR
        and #%11111110        ;clear carry bit &...
        sta reg_sr,s          ;rewrite
        jmp COP_EXIT

; Exit SysCall with error value in .A
sys_error:
.a16
        sta reg_a,s           ;overwrite .C’s stack copy
        ; Flag an error by setting the carry bit in SR:
        _a8
        lda reg_sr,s          ;stack copy of SR
        ora #%00000001        ;set carry bit &...
        sta reg_sr,s          ;rewrite
        jmp COP_EXIT
