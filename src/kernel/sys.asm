; SysCall implementation
.export sys_init,SYSCALL_TASK,SYSCALL_LOCK
.export apioff,apidptab,sparmtab

.import COP_ISR
.import API_read,API_write

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
        .addr API_read
        .addr API_write

;
; System Call API parameters count
;
sparmtab:
        .word 4
        .word 4

.code
.a16
.i16

sys_init:
        ; Set COP vector
        lda #COP_ISR
        sta $ffe4           ; Native COP vector

        _a8
        stz SYSCALL_LOCK
        _a16

        rts

