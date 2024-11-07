.include "ria.inc"

.export hello_world

.P816
.A8
.I8

.org    $0200

hello_world:
        ldx #$00        ; X = 0
loop:   bit RIA_UARTS   ; N = ready to send
        bpl loop        ; If N = 0 goto loop
        lda text,x      ; A = text[X]
        sta RIA_UARTD   ; UART Tx A
        inx             ; X = X + 1
        cmp #$00        ; if A - 0 ...
        bne loop        ; ... != 0 goto loop
        lda #$FF        ; A = 255, OS exit()
        sta RIA_API_OP  ; Halt 6502
text:
.byte   "Hello, World!"
.byte   $0D, $0A, $00
