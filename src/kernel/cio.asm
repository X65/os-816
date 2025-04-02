.export CIO_init
.export CIO_open

.import dev_handlers_tab
.import sys_error,sys_success

.include "kernel/api.inc"
.include "dev/dev.inc"
.include "errors.inc"

.macpack generic
.include "macros.inc"

; Central Input/Output Control Block (8 bytes)
.struct CIOCB
        device  .addr   ; Device Handler Address
        subdev  .byte   ; Subdevice Number
        status  .byte   ; Operation Status
        buffer  .faraddr; Data Buffer Address (supplied by user)
        _res    .res 1  ; Reserved
.endstruct

MAX_CIOCB = 256

.segment "CIOCB"
CIOCBS: .res (256 * .sizeof(CIOCB))

.code
.a16
.i16

CIO_init:
        stz CIOCBS
        ; clear tasks control blocks
        ldx #CIOCBS
        ldy #CIOCBS+2
        lda #MAX_CIOCB * .sizeof(CIOCB) - 3
        mvn 0,0

        ; TODO: fill #0 with "invalid descriptor" device

        ; Call every handler init()
        ldy #DEV_HANDLER::init  ; init function offset
        ldx #0
:       _a8
        lda dev_handlers_tab,x
        _a16
        beq :+
        inx

        ; will "JSR" to CIO handler function, by manipulating stack
        per CIO_init_cont-1     ; push the return address
        lda dev_handlers_tab,x  ; load dev handlers table address
        pha                     ; store to stack
        lda (1,s),y             ; load init function address
        dec A                   ; RTS address on stack is -1 of the return address
        sta 1,s                 ; store the address to stack
        rts                     ; "return" to just pushed address
CIO_init_cont:
        inx
        inx
        bra :-
:
        rts

;
;    user stack frame...
;
path    =s_regsf+1          ; buffer pointer
device  =path+2             ; High byte - subdevice no; Low byte - device letter

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
        sta CIOCBS+CIOCB::subdev,x  ; save subdevice number

        stz CIOCBS+CIOCB::status,x  ; clear status
        stz CIOCBS+CIOCB::buffer,x  ; clear buffer address
        _a16
        stz CIOCBS+CIOCB::buffer+1,x; clear buffer address

        lda dev_handlers_tab+1,y    ; copy handler address
        sta CIOCBS+CIOCB::device,x  ; to CIOCB

        ; Now compute the index of CIOCB
        txa
        lsr
        lsr
        lsr ; divide by 8

        sta reg_a,s     ; overwrite .C’s stack copy
        jmp sys_success
