.struct RIA
    .org    $FFC0

    ; math accelerator
    opera       .word
    operb       .word
    mulab       .word
    divab       .word

    ; monotonic clock
    tm          .byte 6
    _tm_res     .byte 2

    ; DMA
    addr_src    .faraddr
    step_src    .byte
    addr_dst    .faraddr
    step_dst    .byte
    count       .byte
    dma_err     .byte

    ; file access
    fda         .byte
    fda_rw      .byte
    fdb         .byte
    fdb_rw      .byte
    _fd_res     .byte 2

    ; UART
    uart_rdy    .byte
    uart_rxtx   .byte

    ; Random Number Generator
    rng         .word

    ; CPU Vectors Native
    cop_n       .addr
    brk_n       .addr
    abort_n     .addr
    nmi_n       .addr

    ; Interrupt Control
    irq_status  .byte
    irq_enable  .byte

    ; CPU Vector Native
    irq_n       .addr

    ; RIA816 API
    stack       .byte
    op          .byte
    errno       .byte
    busy        .byte

    ; CPU Vector Emulation
    cop_e       .addr

    ; Extension devices
    extio       .byte
    extmem      .byte

    ; CPU Vector Emulation
    abort_e     .addr
    nmi_e       .addr
    reset_e     .addr
    irq_brk_e   .addr
.endstruct

.struct TIMERS
    .org    $FF88
    ; CIA compatible timers
    ta_lo       .byte
    ta_hi       .byte
    tb_lo       .byte
    tb_hi       .byte
    _t_res      .byte
    icr         .byte
    cra         .byte
    crb         .byte
.endstruct

.struct GPIO
    .org    $FF80
    ; GPIO ports
    in0         .byte
    in1         .byte
    out0        .byte
    out1        .byte
    pol0        .byte
    pol1        .byte
    cfg0        .byte
    cfg1        .byte
.endstruct

RIA_API_HALT        = $FF
RIA_API_GET_CHARGEN = $10
