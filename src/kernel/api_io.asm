.export API_read,API_write

.import COP_EXIT

.include "api.inc"
.include "hw/ria.inc"

.include "macros.inc"

.smart

;
;    user stack frame...
;
bufptr  =s_regsf+1          ; buffer pointer
buflen  =bufptr+2           ; buffer length

;
; READ from UART
;
API_read:
        rep #%00110000      ; 16 bit accumulator and index

        ldy #0              ; buffer index

        lda buflen,s        ; get length
        beq @read_exit      ; exit if no buffer space

        tax                 ; copy counter

        _a8
@read_loop:
        bit RIA::uart_rdy
        bvc @read_exit      ; exit if no data pending

        lda RIA::uart_rxtx
        sta (bufptr,s),y    ; store byte in buffer
        iny
        dex
        bne @read_loop

@read_exit:
        _a16
        tya
        sta reg_a,s           ;overwrite .C’s stack copy
        jmp COP_EXIT

;
; WRITE to UART
;
API_write:
        rep #%00110000      ; 16 bit accumulator and index

        ldy #0              ; buffer index

        lda buflen,s        ; get length
        beq @write_exit     ; exit if nothing to write

        tax                 ; copy counter

        _a8
@write_loop:
        bit RIA::uart_rdy
        bpl @write_exit     ; exit if no TX possible

        lda (bufptr,s),y    ; load byte from buffer
        sta RIA::uart_rxtx
        iny
        dex
        bne @write_loop

@write_exit:
        _a16
        tya
        sta reg_a,s           ;overwrite .C’s stack copy
        jmp COP_EXIT

