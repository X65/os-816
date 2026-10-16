// Display initialisation
//
// This assumes CIO is ready and S: is after init
//

import "cgia.kk"
import "ria.kk"
import "../macros.kk"

const dspl_buffer_width  = 48
const dspl_buffer_height = 30
const dspl_buffer_size   = dspl_buffer_width * dspl_buffer_height

segment DISPLAY
var dspl_text_buffer[$0800]
var dspl_chargen[$0800]
var dspl_fg_buffer[$0800]
var dspl_bg_buffer[$0800]

segment RODATA
data dspl_display_list {
    byte [CGIA_DL_IN_LOAD_SCAN | CGIA_DL_IN_LMS|CGIA_DL_IN_LFS|CGIA_DL_IN_LBS|CGIA_DL_IN_LCG]
    word dspl_text_buffer
    word dspl_fg_buffer
    word dspl_bg_buffer
    word dspl_chargen
    repeat 30 { byte CGIA_DL_IN_MODE2 }
    byte [CGIA_DL_IN_JUMP | CGIA_DL_IN_VBL]
    word dspl_display_list
}

segment CODE
func dspl_init @a16 @i16 {
    // initialize CGIA
    stz CGIA.planes // shut off all planes
    // clear all CGIA registers
    ldx #CGIA:sizeof - 2
    loop {
        stz CGIA,x
        dex
        dex
    } while >=0

    @a8 {
        // set initial buffer values
        stz dspl_text_buffer
        lda #text_mode_fg_color
        sta dspl_fg_buffer
        lda #text_mode_bg_color
        sta dspl_bg_buffer

        // drop anything left on XSTACK
        lda #RIA_API_ZXSTACK
        sta RIA.op

        // fetch character generator from RIA firmware
        phb
        pla
        sta RIA.stack           // bank address
        lda #&>dspl_chargen     // high byte
        sta RIA.stack
        lda #&<dspl_chargen     // low byte
        sta RIA.stack
        stz RIA.stack           // code page high byte
        stz RIA.stack           // code page low byte (0 = default font)
        lda #RIA_API_GET_CHARGEN
        sta RIA.op
    }
    // clear character memory
    ldx #dspl_text_buffer
    ldy #dspl_text_buffer+1
    lda #dspl_buffer_size - 2
    mvn 0,0
    // fill foreground memory
    ldx #dspl_fg_buffer
    ldy #dspl_fg_buffer+1
    lda #dspl_buffer_size - 2
    mvn 0,0
    // fill background memory
    ldx #dspl_bg_buffer
    ldy #dspl_bg_buffer+1
    lda #dspl_buffer_size - 2
    mvn 0,0

    // set display list offset
    lda #dspl_display_list
    sta CGIA.offset0
    @a8 {
        // set row height to 8 pixels
        lda #7
        sta CGIA.plane0+CGIA_PLANE_BCKGND.row_height:offsetof
        // match border to text background
        lda #text_mode_bg_color
        sta CGIA.back_color

        // do not wait for character generator transfer to complete
        // it should be done when we actually start puting anything on screen

        // and finally enable the plane
        lda #%00000001
        sta CGIA.planes
    }

    // TODO: Setup S: to use values configured above
}
