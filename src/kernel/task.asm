.include "kernel/task.inc"
.include "kernel/api.inc"

.include "macros.inc"

.macpack generic

.export CURRENT_TASK,NEXT_TASK
.export TASKS, task_init,task_create, task_status_symbol
.export task00,task01,task02,task03,task04,task05,task06,task07,task08,task09,task0A,task0B,task0C,task0D,task0E,task0F,task10,task11,task12,task13,task14,task15,task16,task17,task18,task19,task1A,task1B,task1C,task1D,task1E,task1F
.export TASK_set_name

.import     sys_success
.import     kstrncpy
.importzp   kstrncpy_src, kstrncpy_dst

.segment "TCB"
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

.data
CURRENT_TASK:   .res 2
NEXT_TASK:      .res 2

task_status_symbol:
        .byte 'F'   ; TASK_FREE
        .byte 'G'   ; TASK_GENESIS
        .byte 'R'   ; TASK_RUNNING
        .byte 'S'   ; TASK_STOPPED
        .byte 'W'   ; TASK_WAITING
        .byte 's'   ; TASK_SIGNAL
        .byte '1'   ; TASK_SINGLE

.code
.a16
.i16
task_init:
        stz TASKS
        ; clear tasks control blocks
        ldx #TASKS
        ldy #TASKS+2
        lda # TASKS_NO * .sizeof(TCB) - 3
        mvn 0,0

        stz CURRENT_TASK
        stz NEXT_TASK

        rts

;   Allocate a task structure for new task in scheduler.
;   Resets the task structure to GENESIS state.
;   You will need to set task start address on task stack,
;   before switching the task to RUNNING state.
; Returns:
;   @.X - task stack pointer
;   @.Y - Task Control Block pointer
task_create:
        ; find free task
        ldx #.sizeof(TCB)       ; task 0 belongs to kernel - start from task #1
:       _a8
        lda TASKS+TCB::state,x
        beq task_create_found   ; TASK_FREE = 0 - use it
        _a16
        txa
        add #.sizeof(TCB)
        tax
        cmp # TASKS_NO * .sizeof(TCB)
        bne :-
        ; no free tasks
        pla         ; restore stack to initial
        lda #$FFFF
        rts
.a8
task_create_found:
        inc TASKS+TCB::state,x  ; move task to TASK_GENESIS state
        _a16
        txa
        asl
        asl
        asl                 ; index is in .B
        ora #$FF            ; set low byte to FF
        sub #s_regsf        ; will store 13 bytes of "preempted" task stack
        sta TASKS+TCB::sp,x ; save as stack-pointer
        phx                 ; save TCB for later
        pha                 ; save SP for later
        stz TASKS+TCB::signals,x    ; zero signals & sigmask
        txa                 ; now clean the rest by copying signals/sigmask
        add #TASKS+TCB::signals
        tax
        add #2
        tay
        lda #.sizeof(TCB) - TCB::signals - 3
        mvn 0,0

        ; now initialize the stack of "preempted" task
        ; with initial registers values and RTI address of program start
        ;
        pla         ; restore task stack pointer address
        tax         ; copy to .X
        stz reg_y,x ; .Y
        stz reg_x,x ; .X
        stz reg_a,x ; .C
        and #$FF00  ; mask to have start of task data in .C
        sta reg_dp,x; .DP - direct page start
        _a8
        xba
        sta reg_db,x; .DB - data bank
        sta reg_pb,x; .PB - program bank
        lda #$32    ; initial status register
        sta reg_sr,x; .SR
        _a16
        stz reg_pc,x; .PC

        ply         ; restore saved TCB to y

        rts

; -----------------------------------------

;
;    user stack frame...
;
nameptr =s_regsf+1              ; name pointer

; SysCall to set Task name
TASK_set_name:
        lda nameptr,s
        sta kstrncpy_src
        phb
        _a8
        pla
        sta kstrncpy_src+2

        stz kstrncpy_dst+2
        _a16
        lda CURRENT_TASK
        add #TCB::name          ; add name offset
        sta kstrncpy_dst

        ldx #TASK_NAME_LEN
        jsr kstrncpy

        jmp sys_success
