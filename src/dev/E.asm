;
; Editor device E:
;

.export dev_E_handler_tab

dev_E_init:
        rts

dev_E_open:
        rts

dev_E_close:
        rts

dev_E_get:
        rts

dev_E_put:
        rts

dev_E_status:
        rts

dev_E_special:
        rts

dev_E_handler_tab:
        .addr dev_E_open
        .addr dev_E_close
        .addr dev_E_get
        .addr dev_E_put
        .addr dev_E_status
        .addr dev_E_special
        .addr dev_E_init
        .byte 0,0
