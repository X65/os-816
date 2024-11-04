RIA_UARTS       = $FFE0     ; UART status register
RIA_UARTD       = $FFE0     ; UART data register

RIA_API_STACK   = $FFFF     ; API stack - WRITE: push call argument(s); READ: pull result(s)
RIA_API_OP      = $FFF1     ; API call - WRITE: start API call of given code
