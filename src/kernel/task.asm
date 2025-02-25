.include "task.inc"

.export TASKS, CURRENT_TASK, task_init
.export task00,task01,task02,task03,task04,task05,task06,task07,task08,task09,task0A,task0B,task0C,task0D,task0E,task0F,task10,task11,task12,task13,task14,task15,task16,task17,task18,task19,task1A,task1B,task1C,task1D,task1E,task1F

.data
TASKS:
task00:  .tag TCB
task01:  .tag TCB
task02:  .tag TCB
task03:  .tag TCB
task04:  .tag TCB
task05:  .tag TCB
task06:  .tag TCB
task07:  .tag TCB
task08:  .tag TCB
task09:  .tag TCB
task0A:  .tag TCB
task0B:  .tag TCB
task0C:  .tag TCB
task0D:  .tag TCB
task0E:  .tag TCB
task0F:  .tag TCB
task10:  .tag TCB
task11:  .tag TCB
task12:  .tag TCB
task13:  .tag TCB
task14:  .tag TCB
task15:  .tag TCB
task16:  .tag TCB
task17:  .tag TCB
task18:  .tag TCB
task19:  .tag TCB
task1A:  .tag TCB
task1B:  .tag TCB
task1C:  .tag TCB
task1D:  .tag TCB
task1E:  .tag TCB
task1F:  .tag TCB

CURRENT_TASK:   .res 2

.a16
.i16
task_init:
        ; clear tasks control blocks
        lda #$00
        sta TASKS
        ldx #TASKS
        ldy #TASKS+1
        lda # TASKS_NO * .sizeof(TCB) - 2
        mvn 0,0

        rts
