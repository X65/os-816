.export kernel_start

.import CURRENT_TASK,NEXT_TASK,task_init,sched_init,sys_init
.import task00,task01,task02

.include "task.inc"
.include "hw/cgia.inc"

.include "macros.inc"

.code
kernel_start:
        rep #%00110000  ; 16 bit data and idx
.a16
.i16

        jsr task_init
        jsr sched_init
        jsr sys_init
        ; TODO: reset CGIA, setup MODE0

; --- vvv --------------- fake tasks !!! -----------------------
        ; Tasks are "preempted", so stacks have "saved" registers
        lda #$1ff - 4 - 9
        sta task01+TCB::sp
        lda #0          ; Program Bank
        sta $1ff - 1    ; off by 1, because acc is 16 bit
        lda #$32
        sta $1ff - 3    ; Status Register
        lda #Task1_start
        sta $1ff - 2
        lda #$0100
        sta $1ff - 6    ; Set Direct Page

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
        sta $2ff - 6    ; Set Direct Page
; --- ^^^ --------------- fake tasks !!! -----------------------
        ; Setup kernel Task (task00)
        tsc
        sta task00+TCB::sp

        ; Set current task
        lda #task00
        sta CURRENT_TASK
        sta NEXT_TASK

        sep #%00110000      ; 8-bit acc & index
.a8
.i8
        lda #CGIA_REG_INT_FLAG_VBI
        sta CGIA::int_enable    ; enable NMI on VBL
        sta CGIA::int_status    ; ACK if any INT is pending

        cli                 ; Enable IRQ interrupts

_loop:  bra _loop

; ------------------ fake tasks !!! -----------------------
;
; Simple counter running in own context
; Demonstrates that A register is preserved
;
Task1_start:
        lda #$01
Task1_loop:
        inc A
        sta $82
        bra Task1_loop

;
; ECHO task continuously reading from UART and writing back
; Demonstrates SYSCALL API calls
;
Task2_start:
        _a16
Task2_loop:
        pea 16                  ; buffer length
        pea Task2_buffer        ; buffer address
        lda #1                  ; READ API no
        cop $21                 ; System Call
        ; .C contains number of characters read
        pha                     ; chars to write
        pea Task2_buffer        ; buffer address
        lda #2                  ; WRITE API no
        cop $21                 ; System Call

        bra Task2_loop
; buffer for chars read/written
Task2_buffer:
        .res 16
