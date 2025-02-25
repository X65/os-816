.segment "INFO"
        .asciiz "OS/816 - Operating System for X65 microcomputer"

.segment "VECTORS"
        .word 0, 0, COP_NT, BRK_NT, ABORT_NT, NMI_NT, 0, IRQ_NT
        .word 0, 0, COP_EM, 0, ABORT_EM, NMI_EM, RESET_VEC, IRQ_EM

.import kernel_start

.segment "STARTUP"
RESET_VEC:
        sei             ; disable interrupts

        clc
        xce             ; switch to Native Mode

        ;     --mx----
        sep #%00110000  ; 8-bit data and idx

                        ; direct page is already 0000 after reset
        ldx #$ff        ; stack is shared with direct page (high byte of X is 00)
        txs

        lda #00         ; set Data Bank to 00
        pha
        plb             ; pull into Data Bank Register

        jmp kernel_start ; no-return


COP_EM:
ABORT_EM:
NMI_EM:
IRQ_EM:
COP_NT:
BRK_NT:
ABORT_NT:
NMI_NT:
IRQ_NT:
        rti             ; do nothing
