; Display initialisation
;
; This assumes CIO is ready and S: is after init
;
.export dspl_init

.include "hw/cgia.inc"
.include "hw/ria.inc"

.include "macros.inc"

.segment "DISPLAY"
.org $2000
dspl_text_buffer:
dspl_fg_buffer = dspl_text_buffer + $1000
dspl_bg_buffer = dspl_fg_buffer   + $0800
dspl_chargen   = dspl_text_buffer + $0800
.reloc

dspl_buffer_width  = 48
dspl_buffer_height = 30
dspl_buffer_size   = dspl_buffer_width * dspl_buffer_height

.segment "RODATA"
dspl_display_list:
    .byte CGIA_DL_IN_LOAD_SCAN | CGIA_DL_IN_LMS|CGIA_DL_IN_LFS|CGIA_DL_IN_LBS|CGIA_DL_IN_LCG
    .addr dspl_text_buffer
    .addr dspl_fg_buffer
    .addr dspl_bg_buffer
    .addr dspl_chargen
    .res 30, CGIA_DL_IN_MODE2
    .byte CGIA_DL_IN_JUMP | CGIA_DL_IN_VBL
    .addr dspl_display_list

.code
.a16
.i16
dspl_init:
        ; initialize CGIA
        stz CGIA::mode
        stz CGIA::planes
        ; clear all CGIA registers
        ldx #CGIA::mode
        ldy #CGIA::mode+2
        lda #.sizeof(CGIA) - 3
        mvn 0,0

        ; set initial buffer values
        stz dspl_text_buffer
        _a8
        lda #text_mode_fg_color
        sta dspl_fg_buffer
        lda #text_mode_bg_color
        sta dspl_bg_buffer

        ; fetch character generator from RIA firmware
        phb
        pla
        sta RIA::stack          ; bank address
        lda #>dspl_chargen      ; high byte
        sta RIA::stack
        lda #<dspl_chargen      ; low byte
        sta RIA::stack
        lda #RIA_API_GET_CHARGEN
        sta RIA::op

        _a16
        ; clear character memory
        ldx #dspl_text_buffer
        ldy #dspl_text_buffer+2
        lda #dspl_buffer_size - 3
        mvn 0,0
        ; fill foreground memory
        ldx #dspl_fg_buffer
        ldy #dspl_fg_buffer+1
        lda #dspl_buffer_size - 2
        mvn 0,0
        ; fill background memory
        ldx #dspl_bg_buffer
        ldy #dspl_bg_buffer+1
        lda #dspl_buffer_size - 2
        mvn 0,0

        ; set display list offset
        lda #dspl_display_list
        sta CGIA::offset0
        _a8
        ; set row height to 8 pixels
        lda #7
        sta CGIA::plane0+CGIA_PLANE_FG::row_height
        ; and finally enable the plane
        lda #%00000001
        sta CGIA::planes
        _a16

        ; TODO: Setup S: to use values configured above

        rts
