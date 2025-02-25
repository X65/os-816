.export sched_init

.import TASKS,CURRENT_TASK,task01,task02

.include "task.inc"
.include "hw/cgia.inc"

.a16
.i16
sched_init:
        ; Set NMI vector
        lda #Sched_NMI_ISR
        sta $ffea           ; Native NMI vector

        rts

Sched_NMI_ISR:
        ; Save current task state
        ; (stack already has PBR, PCH, PCL and P from NMI)
        rep #%00110000  ; use 16-bit data and idx
        pha             ; Save A
        phx             ; Save X
        phy             ; Save Y
        phd             ; Save D
        phb             ; Save DBR

        ; Save Stack Pointer
        tsc
        tay

        ; Restore kernel stack
        lda TASKS+TCB::sp
        tcs
        ; Set kernel Direct Page
        lda #00
        tcd

        ; Save SP to TCB
        ldx CURRENT_TASK
        sty TCB::sp, x

        ; Switch to next task
        jsr Sched_uler

        ; Restore new task state
        ldx CURRENT_TASK
        lda TCB::sp, x          ; Load task's SP
        tcs                     ; Restore stack pointer

        plb                     ; Restore saved registers
        pld
        ply
        plx
        pla

        sta CGIA::int_status    ; ACK NMI interrupt
        rti                     ; Return to new task

Sched_uler:
        lda #task01
        cmp CURRENT_TASK
        beq Sched_SwitchTo2
        sta CURRENT_TASK
        rts
Sched_SwitchTo2:
        lda #task02
        sta CURRENT_TASK
        rts
