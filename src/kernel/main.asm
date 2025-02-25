.export kernel_start

.import task_init,CURRENT_TASK,task00,task01,task02
.import sched_init

.include "task.inc"
.include "macros.inc"
.include "hw/cgia.inc"

kernel_start:
        rep #%00110000  ; 16 bit data and idx
.a16
.i16

        jsr task_init
        jsr sched_init
        ; TODO: reset CGIA, setup MODE0

; --- vvv --------------- fake tasks !!! -----------------------
        ; Task1 is "running", so its stack is empty
        lda #$1ff
        sta task01+TCB::sp

        ; Task2 is "preempted", so its stack has "saved" registers
        lda #$2ff - 4 - 9
        sta task02+TCB::sp
        lda #0          ; Program Bank
        sta $2ff - 1    ; off by 1, because acc is 16 bit
        lda #$32
        sta $2ff - 3    ; Status Register
        lda #Task2_start
        sta $2ff - 2
        lda #$0200
        sta $2ff - 3 - 8; Set Direct Page
; --- ^^^ --------------- fake tasks !!! -----------------------
        ; Setup kernel Task (task00)
        tsc
        sta task00+TCB::sp

        ; Set current task to Task 1
        lda #task01
        sta CURRENT_TASK
        lda #$0100
        tcd         ; Set Direct Page
        lda task01+TCB::sp
        tcs         ; Set Stack Pointer

        sep #%00110000      ; 8-bit acc & index
.a8
.i8
        cli                 ; Enable IRQ interrupts

        lda #CGIA_REG_INT_FLAG_VBI
        sta CGIA::int_enable    ; trigger NMI on VBL

        jml Task1_start     ; Jump to first task

; ------------------ fake tasks !!! -----------------------
Task1_start:
        lda #$01
Task1_loop:
        inc A
        sta $82
        bra Task1_loop

Task2_start:
        lda #$FF
Task2_loop:
        dec A
        sta $84
        bra Task2_loop
