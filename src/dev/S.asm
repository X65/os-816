;
; Screen device S:
;

.export dev_S_handler_tab

dev_S_init:
        rts

dev_S_open:
        rts

dev_S_close:
        rts

dev_S_get:
        rts

dev_S_put:
        rts

dev_S_status:
        rts

dev_S_special:
        rts

dev_S_handler_tab:
    .addr dev_S_open
    .addr dev_S_close
    .addr dev_S_get
    .addr dev_S_put
    .addr dev_S_status
    .addr dev_S_special
    .addr dev_S_init
    .byte 0,0
