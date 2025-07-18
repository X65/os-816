;
; Keyboard device K:
;

.export dev_K_handler_tab

dev_K_init:
        rts

dev_K_open:
        rts

dev_K_close:
        rts

dev_K_get:
        rts

dev_K_put:
        rts

dev_K_status:
        rts

dev_K_special:
        rts

dev_K_handler_tab:
        .addr dev_K_open
        .addr dev_K_close
        .addr dev_K_get
        .addr dev_K_put
        .addr dev_K_status
        .addr dev_K_special
        .addr dev_K_init
        .byte 0,0
