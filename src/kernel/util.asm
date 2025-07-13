.include "macros.inc"

.exportzp   kstrncpy_src, kstrncpy_dst
.export     kstrncpy

.zeropage
kstrncpy_src: .res 3
kstrncpy_dst: .res 3

.code
.a16
.i16
; set kstrncpy_src and kstrncpy_dst before call
; .x - copy max n chars
kstrncpy:
        ldy #0
kstrncpy_loop:
        dex
        bpl :+
        rts
:       _a8
        lda [kstrncpy_src],y
        sta [kstrncpy_dst],y
        _a16
        beq :+
        iny
        bra kstrncpy_loop
:       rts
