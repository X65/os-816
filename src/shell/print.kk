import "../macros.kk"
import "../errors.kk"
import "../kernel/api.kk"
import "../generic.kk"

var dp shell_str_ptr[2]

// Print a nul-terminated string
// pointed by Accumulator
func print_string @a16 @i16 {
    sta shell_str_ptr

    // Print a nul-terminated string
    // pointed by zp:shell_str_ptr
shell_print:
    @a8
    // Find the length of the string
    ldy #0
.loop:
    lda (shell_str_ptr),y
    beq .skip
    iny
    bra .loop
.skip:
    phy
    @a16
    lda shell_str_ptr
    pha
    lda #CON_WRITE
    cop #$21
}

// --------------------------------------------
var print_str_buf[4]

// --------------------------------------------
// Print a number in .A in HEX
naked print_hex @i16 {
    @a8
    pha                     // save the number
    // low nybble
    and #$0F                // extract low nybble
    cmp #10                 // less than 10?
    >= {
        add #('A'-10)           // convert to letter
    } else { // use digit
        add #'0'                // convert to digit
    }
    sta print_str_buf+1
    // high nybble
    pla
    lsr                     // extract high nybble
    lsr
    lsr
    lsr
    cmp #10                 // less than 10?
    >= {
        add #('A'-10)           // convert to letter
    } else { // use digit
        add #'0'                // convert to digit
    }
    sta print_str_buf
    stz print_str_buf+2     // nul-terminator
    @a16
    lda #print_str_buf
    jmp print_string
}

// --------------------------------------------
func write_char {
    @a8
    sta print_str_buf
    @a16
    per 1                   // write one byte
    per print_str_buf
    lda #CON_WRITE
    cop #$21
}
