.export dev_handlers_tab

.import dev_S_handler_tab,dev_K_handler_tab,dev_E_handler_tab

;
; Device handlers
;
dev_handlers_tab:
    ; Screen device
    .byte 'S'
    .addr dev_S_handler_tab
    ; Keyboard device
    .byte 'K'
    .addr dev_K_handler_tab
    ; Editor device
    .byte 'E'
    .addr dev_E_handler_tab
    ; End of table
    .byte 0
