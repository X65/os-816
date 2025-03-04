; Interrupt Service Routines
.export NMI_ISR,COP_ISR

.import Sched_uler,SYSCALL_TASK,SYSCALL_LOCK
.import CURRENT_TASK,NEXT_TASK,TASKS

.include "task.inc"
.include "hw/cgia.inc"

.code
.a16
.i16

.macro isr_prologue
        ; Save current task state
        ; (stack already has PBR, PCH, PCL and P)
        phb             ; Save DB
        phd             ; Save DP
        rep #%00110000  ; use 16-bit data and idx
        .a16
        .i16
        pha             ; Save .C
        phx             ; Save .X
        phy             ; Save .Y
.endmacro
.macro isr_epilogue
        ply
        plx
        pla
        pld
        plb
.endmacro

.macro kernel_context
        ; Set kernel Direct Page
        lda #00
        tcd
        ; Set OS data bank for access to kernel data
        pha
        plb
        plb     ; pull second time as pushed C took two bytes
.endmacro


; -----------------------------------------------------------------------------
; Interrupt triggered by VBL every 1/60sec
; Used to call task scheduler switching tasks
; -----------------------------------------------------------------------------
NMI_ISR:
        isr_prologue
        kernel_context

        ; TODO: periodic tasks, timekeeping etc.

        ; Switch to next task
        jsr Sched_uler

        ; Check whether we should switch tasks or return to kernel
        lda SYSCALL_LOCK
        bne @in_syscall
        ldx NEXT_TASK           ; Return to new task state
        lda TCB::sp, x          ; Load task's SP
        tcs                     ; Restore stack pointer
        stx CURRENT_TASK        ; Set new task as current
@in_syscall:

        isr_epilogue

        sep #%00100000
        .a8
        sta CGIA::int_status    ; ACK NMI interrupt

        rti

; -----------------------------------------------------------------------------
; Interrupt triggered by COP instruction
; Main entry to OS SysCall interface
; -----------------------------------------------------------------------------
COP_ISR:
        ; block scheduler
        sep #%00100000
        .a8
        inc SYSCALL_LOCK
        isr_prologue
        kernel_context

        tsc
        ldx CURRENT_TASK
        sta TCB::sp, x  ; Save SP to TCB
        stx SYSCALL_TASK

        cli     ; re-enable regular interrupts

        ; do SysCall
        inc $111

        ; Restore current/new task state (NEXT_TASK could change during syscall)
        ldx NEXT_TASK
        lda TCB::sp, x          ; Load task's SP
        tcs                     ; Restore stack pointer
        stx CURRENT_TASK

        isr_epilogue

        ; unblock sheduler
        stz SYSCALL_LOCK
        rti
