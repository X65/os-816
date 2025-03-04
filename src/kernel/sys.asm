; SysCall implementation
.export sys_init,SYSCALL_TASK,SYSCALL_LOCK

.import COP_ISR

.include "macros.inc"

.data
SYSCALL_TASK:   .res 2
SYSCALL_LOCK:   .res 2  ; two bytes, so we can use 16-bit STZ

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
