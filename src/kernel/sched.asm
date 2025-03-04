.export sched_init,Sched_uler

.import NMI_ISR
.import CURRENT_TASK,NEXT_TASK,TASKS,task01,task02

.code
.a16
.i16

sched_init:
        ; Set NMI vector
        lda #NMI_ISR
        sta $ffea           ; Native NMI vector

        rts

Sched_uler:
        lda #task01
        cmp CURRENT_TASK
        beq Sched_SwitchTo2
        sta NEXT_TASK
        rts
Sched_SwitchTo2:
        lda #task02
        sta NEXT_TASK
        rts
