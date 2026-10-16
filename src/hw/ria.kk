var RIA[
    // math accelerator
    .opera      :word
    .operb      :word
    .mulab      :byte [4]           // 32-bit product
    .divab      :word

    // monotonic clock
    .tm         :byte [6]

    // DMA
    .addr_src   :far
    .step_src   :byte
    .addr_dst   :far
    .step_dst   :byte
    .count      :byte
    .dma_err    :byte

    // file access
    .fda        :byte
    .fdb        :byte
    .fda_rw     :byte
    .fdb_rw     :byte
    .fda_st     :byte
    .fdb_st     :byte

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
    .irq_enable :byte
    .irq_status :byte

    // CPU Vector Native
    .irq_n      :word

    // RIA816 API
    .op         :byte               // Write: start op / Read: return value low byte
    .ret_hi     :byte               // return value high byte
    .stack      :byte               // XSTACK push/pop
    .status     :byte               // [B......E] B - busy, E - error

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

var HID[
    // HID devices
    // Write d0: select device [AAAADDDD] D - device type, A - device address/index
    // Read: device dependent
    .d          :byte [16]
] = $FFB0

var BUZZ[
    // System buzzer
    .freq       :word               // logarithmic frequency
    .duty       :byte
    ._res       :byte
] = $FFA8

var RGB[
    // RGB LEDs
    .led        :byte [4]           // direct RGB332 colour of LED 0-3
    .idx        :byte               // LED chain index - write commits
    .red        :byte
    .green      :byte
    .blue       :byte
] = $FFA0

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
] = $FF98

var GPIO[
    // GPIO ports
    .in0    :byte
    .in1    :byte
    .out0   :byte
    .out1   :byte
    .pol0   :byte
    .pol1   :byte
    .cfg0   :byte
    .cfg1   :byte
    .str0l  :byte
    .str0h  :byte
    .str1l  :byte
    .str1h  :byte
    .ltch0  :byte
    .ltch1  :byte
    .ple0   :byte
    .ple1   :byte
    .pls0   :byte
    .pls1   :byte
    .inte0  :byte
    .inte1  :byte
    .inst0  :byte
    .inst1  :byte
    ._g_res :byte
    .outcf  :byte
] = $FF80

const RIA_API_STATUS_BUSY = %10000000
const RIA_API_STATUS_ERR  = %00000001

const RIA_IRQ_TIMERS = %00000001
const RIA_IRQ_GPIO   = %00000010

const RIA_HID_DEV_KEYBOARD = $00
const RIA_HID_DEV_MOUSE    = $01
const RIA_HID_DEV_GAMEPAD  = $02

const RIA_API_ZXSTACK     = $00
const RIA_API_GET_CHARGEN = $10
const RIA_API_HALT        = $FF
