.include "macros.inc"

.exportzp   kstrncpy_src, kstrncpy_dst
.export     kstrncpy

.zeropage
kstrncpy_src: .res 3
kstrncpy_dst: .res 3

.code
.a16
.i16

;
; Copy `.X` non-null bytes from `kstrncpy_src` to `kstrncpy_dst`.
;
; @param {register} .A         - copy max n chars
; @param {global} kstrncpy_src - source far-address (24bit)
; @param {global} kstrncpy_dst - destination far-address (24bit)
; @modifies .A, .X, .Y
;
.proc kstrncpy
        ldy #0
        tax
        beq exit
        _a8
loop:   lda [kstrncpy_src],y
        sta [kstrncpy_dst],y
        beq exit
        iny
        dex
        bne loop
exit:   _a16
        rts
.endproc
