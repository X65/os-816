.segment "INFO"
        .asciiz "OS/816 - Operating System for X65 microcomputer"

.segment "VECTORS"
        .word 0, 0, NOP_ISR, STOP_ISR, NOP_ISR, NOP_ISR, 0, NOP_ISR
        .word 0, 0, NOP_ISR, 0, NOP_ISR, NOP_ISR, RESET_HDL, NOP_ISR

.import kernel_start

.include "hw/ria.inc"

.segment "STARTUP"
RESET_HDL:
        sei                     ; disable interrupts

        clc
        xce                     ; switch to Native Mode

        ;     --mx----
        sep #%00110000          ; 8-bit data and idx
        .a8
        .i8

                                ; direct page is already 0000 after reset
        ldx #$ff                ; stack is shared with direct page (high byte of X is 00)
        txs

        lda #00                 ; set Data Bank to 00
        pha
        plb                     ; pull into Data Bank Register

        jmp kernel_start        ; no-return


NOP_ISR:
        rti                     ; do nothing

STOP_ISR:
        sep #%00110000
        .a8
        .i8
        lda #$FF
        sta RIA::op
