.import hello_world

.P816
.A8
.I8

.segment "STARTUP"

RESET:
        sei             ; disable interrupts
        cld             ; disable decimal mode

        clc
        xce             ; switch to Native Mode

        ;     --mx----
        sep #%00110000  ; 8 bit data and idx

        ldx #$ff        ; stack is shared with zero page (high byte of X is 00)
        txs

        ; TODO: reset CGIA, setup MODE0

        cli             ; enable interrupts

        jmp hello_world ; continue to main program start


COP_HDL:
BRK_HDL:
ABORT_HDL:
NMI_HDL:
IRQ_HDL:
        rti             ; do nothing


.segment "VEC816"
.word COP_HDL   ; COP    65816 vector.
.word BRK_HDL   ; BRK    65816 vector.
.word ABORT_HDL ; ABORTB 65816 vector.
.word NMI_HDL   ; NMIB   65816 vector.
.word $0000     ;
.word IRQ_HDL   ; IRQB   65816 vector.

.segment "VEC02"
.word ABORT_HDL ; ABORTB   65816 vector.
.word NMI_HDL   ; NMIB     6502 ector.
.word RESET     ; RESETB   6502 vector.
.word IRQ_HDL   ; IRQB/BRK 6502 vector.
