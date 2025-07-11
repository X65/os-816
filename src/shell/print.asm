.exportzp shell_str_ptr
.export print_string, shell_print
.export print_hex, write_char

.include "macros.inc"
.include "errors.inc"
.include "kernel/api.inc"

.macpack generic

.zeropage
shell_str_ptr:
    .addr 0

.code
    .a16
    .i16

; Print a nul-terminated string
; pointed by Accumulator
print_string:
    sta shell_str_ptr

    ; Print a nul-terminated string
    ; pointed by zp:shell_str_ptr
shell_print:
    _a8
    ; Find the length of the string
    ldy #0
:   lda (shell_str_ptr),y
    beq :+
    iny
    bra :-
:   phy
    _a16
    lda shell_str_ptr
    pha
    lda #CON_WRITE
    cop $21
    rts

; --------------------------------------------
print_str_buf:
    .res 4

; --------------------------------------------
; Print a number in .A in HEX
print_hex:
    _a8
    pha         ; save the number
    ; low nybble
    and #$0F    ; extract low nybble
    cmp #10     ; less than 10?
    blt :+      ; use digit
    add #('A'-10)   ; convert to letter
    bra print_hex_next
:   add #'0'        ; convert to digit
print_hex_next:
    sta print_str_buf+1
    ; high nybble
    pla
    lsr         ; extract high nybble
    lsr
    lsr
    lsr
    cmp #10     ; less than 10?
    blt :+      ; use digit
    add #('A'-10)   ; convert to letter
    bra print_hex_finish
:   add #'0'        ; convert to digit
print_hex_finish:
    sta print_str_buf
    stz print_str_buf+2 ; nul-terminator
    _a16
    lda #print_str_buf
    jmp print_string

; --------------------------------------------
write_char:
    _a8
    sta print_str_buf
    _a16
    per 1   ; write one byte
    per print_str_buf
    lda #CON_WRITE
    cop $21
    rts
