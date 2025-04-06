; Debugging utilities
;
.export dbg_task

.include "macros.inc"

.code
.a16
.i16

;
; Simple counter running in own context
; Demonstrates that A register is preserved
;
dbg_task:
        rep #%00110000      ; 16-bit acc & index
.a16
.i16
        lda #$01
:       inc A
        sta $82
        bra :-
