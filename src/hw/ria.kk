var RIA[
    // math accelerator
    .opera      :word
    .operb      :word
    .mulab      :word
    .divab      :word

    // monotonic clock
    .tm         :byte [6]
    ._tm_res    :byte [2]

    // DMA
    .addr_src   :far
    .step_src   :byte
    .addr_dst   :far
    .step_dst   :byte
    .count      :byte
    .dma_err    :byte

    // file access
    .fda        :byte
    .fda_rw     :byte
    .fdb        :byte
    .fdb_rw     :byte
    ._fd_res    :byte [2]

    // UART
    .uart_rdy   :byte
    .uart_rxtx  :byte

    // Random Number Generator
    .rng        :word

    // CPU Vectors Native
    .cop_n      :word
    .brk_n      :word
    .abort_n    :word
    .nmi_n      :word

    // Interrupt Control
    .irq_status :byte
    .irq_enable :byte

    // CPU Vector Native
    .irq_n      :word

    // RIA816 API
    .stack      :byte
    .op         :byte
    .errno      :byte
    .busy       :byte

    // CPU Vector Emulation
    .cop_e      :word

    // Extension devices
    .extio      :byte
    .extmem     :byte

    // CPU Vector Emulation
    .abort_e    :word
    .nmi_e      :word
    .reset_e    :word
    .irq_brk_e  :word
] = $FFC0

var TIMERS[
    // CIA compatible timers
    .ta_lo  :byte
    .ta_hi  :byte
    .tb_lo  :byte
    .tb_hi  :byte
    ._t_res :byte
    .icr    :byte
    .cra    :byte
    .crb    :byte
] = $FF88

var GPIO[
    // GPIO ports
    .in0  :byte
    .in1  :byte
    .out0 :byte
    .out1 :byte
    .pol0 :byte
    .pol1 :byte
    .cfg0 :byte
    .cfg1 :byte
] = $FF80

const RIA_API_HALT        = $FF
const RIA_API_GET_CHARGEN = $10
