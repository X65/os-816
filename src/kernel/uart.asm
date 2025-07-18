.export UART_read,UART_write

.import sys_success

.include "kernel/api.inc"
.include "hw/ria.inc"

.include "macros.inc"

.code
.a16
.i16
;
;    user stack frame...
;
bufptr  =s_regsf+1              ; buffer pointer
buflen  =bufptr+2               ; buffer length

;
; READ from UART
;
UART_read:
        ldy #0                  ; buffer index

        lda buflen,s            ; get length
        beq @read_exit          ; exit if no buffer space

        tax                     ; copy counter

        _a8
@read_loop:
        bit RIA::uart_rdy
        bvc @read_exit          ; exit if no data pending

        lda RIA::uart_rxtx
        sta (bufptr,s),y        ; store byte in buffer
        iny
        dex
        bne @read_loop

@read_exit:
        _a16
        tya
        jmp sys_success

;
; WRITE to UART
;
UART_write:
        ldy #0                  ; buffer index

        lda buflen,s            ; get length
        beq @write_exit         ; exit if nothing to write

        tax                     ; byte counter

        _a8
@write_loop:
        bit RIA::uart_rdy
        bpl @write_exit         ; exit if no TX possible

        lda (bufptr,s),y        ; load byte from buffer
        sta RIA::uart_rxtx
        iny
        dex                     ; decrease byte counter
        bne @write_loop

@write_exit:
        _a16
        tya
        jmp sys_success

