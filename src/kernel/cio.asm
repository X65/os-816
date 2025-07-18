.export CIO_init
.export CIO_open
.export CIO_close
.export CIO_read
.export CIO_write
.export CIO_dup

.import dev_handlers_tab
.import sys_error,sys_success
.import CURRENT_TASK

.include "kernel/api.inc"
.include "kernel/task.inc"
.include "dev/dev.inc"
.include "errors.inc"

.macpack generic
.include "macros.inc"

; Central Input/Output Control Block (8 bytes)
.struct CIOCB
        device  .addr           ; Device Handler Address
        subdev  .byte           ; Subdevice Number
        status  .byte           ; Operation Status
        buffer  .faraddr        ; Data Buffer Address (supplied by user)
        _res    .res 1          ; Reserved
.endstruct

MAX_CIOCB = 256

.segment "CIOCB"
CIOCBS: .res (256 * .sizeof(CIOCB))

.code
.a16
.i16

CIO_init:
        ;
        stz CIOCBS
        ; clear CIO control blocks
        ldx #CIOCBS
        ldy #CIOCBS+2
        lda #MAX_CIOCB * .sizeof(CIOCB) - 3
        mvn 0,0

        ; TODO: fill #0 with "invalid descriptor" device

        ; Call every handler init()
        ldy #0
:       _a8
        lda dev_handlers_tab,y  ; load handler letter or NUL if end of table
        _a16
        beq :+                  ; exit when reached end of dev_handlers_tab marker
        iny                     ; move to point to handler's procedures table
        lda dev_handlers_tab,y  ; load dev handlers table address
        add #DEV_HANDLER::init  ; add init function offset
        tax
        jsr ($0000,x)           ; JSR to init procedure
        iny
        iny                     ; move over address to next entry
        bra :-
:
        rts

;
;    user stack frame...
;
path    =s_regsf+1              ; buffer pointer
device  =path+2                 ; High byte - subdevice no; Low byte - device letter

;
; OPEN CIOCB
;
CIO_open:
        ; Find an available CIOCB
        ldx #0      ; CIOCB index
:       lda CIOCBS,x
        beq :+
        txa
        add #.sizeof(CIOCB)
        tax
        cmp #256 * .sizeof(CIOCB)
        bne :-      ; continue searching

        lda #EMFILE ; No more CIOCBs available
        jmp sys_error

:       ; .X contains free CIOCB index
        _a8
        ; Find device letter handler
        ldy #0
CIO_open_check_dev_handlers_letter:
        lda dev_handlers_tab,y
        bne :+
        ; Reached end of device table
        _a16
        lda #ENODEV
        jmp sys_error
.a8
:       cmp device,s
        beq :+      ; found device letter handler
        iny
        iny
        iny
        bra CIO_open_check_dev_handlers_letter

:       ; .Y contains device letter handler
        xba
        sta CIOCBS+CIOCB::subdev,x      ; save subdevice number

        stz CIOCBS+CIOCB::status,x      ; clear status
        stz CIOCBS+CIOCB::buffer,x      ; clear buffer address
        _a16
        stz CIOCBS+CIOCB::buffer+1,x    ; clear buffer address

        lda dev_handlers_tab+1,y        ; copy handler table address
        sta CIOCBS+CIOCB::device,x      ; to CIOCB

        txy                     ; save .X in .Y

        ; Call handler's open procedure
        add #DEV_HANDLER::open  ; add open function offset
        tax
        jsr ($0000,x)           ; JSR to open procedure

        ; Now compute the index of CIOCB
        tya     ; get saved from .Y
        lsrx 3  ; divide by 8

        sta reg_a,s             ; overwrite .C’s stack copy
        jmp sys_success

; user stack frame
fileno  =s_regsf+1 ; file descriptor number

;
; CLOSE CIOCB
;
CIO_close:
        ldx CURRENT_TASK
        lda TCB::fds,x


        lda #EINVAL
        jmp sys_error

;
; READ CIOCB
;
CIO_read:
        lda #EINVAL
        jmp sys_error

;
; WRITE CIOCB
;
CIO_write:
        lda #EINVAL
        jmp sys_error

;
; Duplicate CIOCB
;
CIO_dup:
        lda #EINVAL
        jmp sys_error
