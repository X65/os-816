.export kernel_start

.import CURRENT_TASK,NEXT_TASK,task_init,sched_init,sys_init,CIO_init,dspl_init
.import TASKS,task00,task01,task02,task_create
.import shell_main,dbg_task

.include "kernel/task.inc"
.include "kernel/api.inc"
.include "hw/cgia.inc"

.include "macros.inc"

.code
kernel_start:
        _ai16   ; 16 bit data and idx

        jsr task_init
        jsr sched_init
        jsr sys_init
        jsr CIO_init
        jsr dspl_init

        ; TODO: Open S: device
        ; and use obtained FD as STDOUT and STDERR of spawned task
        ; pea 'S'         ; S0: .A - device; .B - subdevice no
        ; pea $0000       ; no path
        ; lda #IO_OPEN
        ; cop $21

        ; ---------------------------------------------------------------------
        ; create two tasks:
        ; - task for preemption debugging
        ; - shell task

        jsr task_create     ; new task stack pointer returned in .X
        lda #dbg_task
        sta reg_pc,x        ; .PC
        _a8
        stz reg_pb,x        ; .PB - override with kernel bank 0
        ; and start the task
        lda #TASK_RUNNING
        sta TASKS+TCB::state,y  ; TCB returned in y
        _a16

        jsr task_create
        lda #shell_main
        sta reg_pc,x        ; .PC
        _a8
        stz reg_db,x        ; .DB - override with kernel bank 0
        stz reg_pb,x        ; .PB - override with kernel bank 0
        lda #TASK_RUNNING
        sta TASKS+TCB::state,y  ; TCB returned in y
        _a16

        ; Setup kernel Task (task00)
        tsc
        sta task00+TCB::sp

        ; Set current task
        lda #task00
        sta CURRENT_TASK
        sta NEXT_TASK

        _ai8                ; 8-bit acc & index
        lda #CGIA_REG_INT_FLAG_VBI
        sta CGIA::int_enable    ; enable NMI on VBL
        sta CGIA::int_status    ; ACK if any INT is pending

        cli                 ; Enable IRQ interrupts

_loop:  bra _loop
