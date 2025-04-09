; Interrupt Service Routines
.export NMI_ISR,COP_ISR,COP_EXIT

.import Sched_uler,SYSCALL_TASK,SYSCALL_LOCK
.import CURRENT_TASK,NEXT_TASK,TASKS
.import sparmtab,apioff,apidptab

.include "task.inc"
.include "api.inc"
.include "hw/cgia.inc"
.include "hw/ria.inc"
.include "macros.inc"

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

        ; Check whether we interrupted a task and should save its state
        lda SYSCALL_LOCK
        bne @in_syscall_1
        ; Save current task SP to TCB
        ldx CURRENT_TASK
        tsc
        sta TCB::sp, x
@in_syscall_1:

        ; TODO: periodic tasks, timekeeping etc.

        ; Switch to next task
        jsr Sched_uler

        ; Check whether we should switch tasks or return to kernel
        lda SYSCALL_LOCK
        bne @in_syscall_2
        ldx NEXT_TASK           ; Return to new task state
        lda TCB::sp, x          ; Load task's SP
        tcs                     ; Restore stack pointer
        stx CURRENT_TASK        ; Set new task as current
@in_syscall_2:

        isr_epilogue

        sep #%00100000
        .a8
        sta f:CGIA::int_status  ; ACK NMI interrupt

        rti

; -----------------------------------------------------------------------------
; Interrupt triggered by COP instruction
; Main entry to OS SysCall interface
; -----------------------------------------------------------------------------
COP_ISR:
        ; save current task state
        ; (stack already has PBR, PCH, PCL and P)
        isr_prologue
        kernel_context

        ; block scheduler preemption
        inc SYSCALL_LOCK        ; lock is two bytes, but we care only about Low
                                ; so it does not matter which mode is M flag

        ldx CURRENT_TASK
        tsc
        sta TCB::sp, x          ; save SP to TCB
        stx SYSCALL_TASK

        cli     ; re-enable regular interrupts

        ;ldy #$FFFF              ; stored PC points to next instruction, so back up -1
        ;lda (reg_pc,s),y        ; load COP argument
        ;and #$00FF              ; mask garbage in .B
        ;                        ; .A contains the API block, should always be $21

        ; do SysCall
        ; http://sbc.bcstechnology.net/65c816interrupts.html#toc:65c816_kertrap_api
        lda reg_a,s           ; load saved copy of .C
        and #$00FF            ; mask garbage in .B (16 bit mask)
        beq icop01            ; API index cannot be zero†
;
        dec a                 ; zero-align API index
        cmp #maxapi           ; index in range (16 bit comparison)?
        bcs icop01            ; no, error†
;
        asl a                 ; double API index for...
        tax                   ; API dispatch table offset
        sta apioff            ; save offset &...
        jmp (apidptab,x)      ; run appropriate code
;
;
;    invalid API index error processing...
;
icop01:
        ; † TODO: core-dump
        _a8
        lda #RIA_API_HALT
        sta RIA::op             ; STOP the machine
@_loop: bra @_loop

COP_EXIT:
        ; SysCall arguments frame cleanup
        ; http://sbc.bcstechnology.net/65c816interrupts.html#toc:post_api
        rep #%00110001        ;select 16 bit registers & clear carry
        .a16
        .i16
        tsc                   ;get SP
        adc #s_regsf+s_libsf  ;add bytes in register & library stack frames
        tax                   ;now is “from” address for stack frame shift
;
        ldy apioff            ;API dispatch offset
        adc sparmtab,y        ;add bytes in user stack frame
        tay                   ;now is “to” address for stack frame shift
;
        lda #s_regsf+s_libsf-1
        mvp #0,#0             ;shift stack frames
;
        tyx                   ;adjust...
        txs                   ;stack pointer

        ldx CURRENT_TASK
        sty TCB::sp, x          ; Save SP to TCB (it is left in Y by MVP)

        ; Restore current/new task state (NEXT_TASK could change during syscall)
        ldx NEXT_TASK
        lda TCB::sp, x          ; Load task's SP
        tcs                     ; Restore stack pointer
        stx CURRENT_TASK

        ; unblock sheduler
        stz SYSCALL_LOCK

        isr_epilogue

        rti
