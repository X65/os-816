import "hw/ria.kk"
import "kernel/main.kk"

segment INFO
data {
    "OS/816 - Operating System for X65 microcomputer" 0
}

// Native: COP BRK ABORT NMI [IRQ_ctrl] IRQ
segment VECTORS_N
data {
    word NOP_ISR STOP_ISR NOP_ISR NOP_ISR 0 NOP_ISR
}

// Emulation: COP [EXTIO/EXTMEM] ABORT NMI RESET IRQ/BRK
segment VECTORS_E
data {
    word NOP_ISR 0 NOP_ISR NOP_ISR RESET_HDL NOP_ISR
}

segment STARTUP
naked RESET_HDL {
    sei                     // disable interrupts

    clc
    xce                     // switch to Native Mode

    //     --mx----
    @a8 @i8                 // 8-bit data and idx

                            // direct page is already 0000 after reset
    ldx #$ff                // stack is shared with direct page (high byte of X is 00)
    txs

    lda #00                 // set Data Bank to 00
    pha
    plb                     // pull into Data Bank Register

    jmp kernel_start        // no-return
}

naked NOP_ISR {
    rti                     // do nothing
}

naked STOP_ISR {
    @a8 @i8
    lda #$FF
    sta RIA.op
}
