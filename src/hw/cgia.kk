const CGIA_COLUMN_PX = 8

const CGIA_DL_MODE_BIT = %00001000
const CGIA_DL_DLI_BIT  = %10000000

const CGIA_PLANE_REGS_NO = 16

abstract var CGIA_PLANE_REGS[
    .regs :byte [CGIA_PLANE_REGS_NO]
]

const CGIA_PLANES                 = 4
const CGIA_AFFINE_FRACTIONAL_BITS = 8
const CGIA_MAX_DL_INSTR           = 32

const PLANE_MASK_TRANSPARENT        = %00000001
const PLANE_MASK_BORDER_TRANSPARENT = %00001000
const PLANE_MASK_DOUBLE_WIDTH       = %00010000

abstract var CGIA_PLANE_FG[
    .flags          :byte
    .border_columns :byte
    .row_height     :byte
    .stride         :byte
    .scroll_x       :byte
    .offset_x       :byte
    .scroll_y       :byte
    .offset_y       :byte
    .shared_color0  :byte
    .shared_color1  :byte
]

abstract var CGIA_PWM[
    .freq         :word
    .duty         :byte
    ._reserved_3  :byte
]

const CGIA_PWMS = 2

var CGIA[
    .mode         :byte
    .bckgnd_bank  :byte
    .sprite_bank  :byte
    ._reserved_3  :byte [(16-3)] // reserved

    .raster       :word
    ._reserved_12 :byte [(6)]    // reserved
    .int_raster   :word
    .int_enable   :byte
    .int_status   :byte
    ._reserved_1C :byte [(4)]    // reserved

    .pwm0[
        .freq         :word
        .duty         :byte
        ._reserved_3  :byte
    ]
    .pwm1[
        .freq         :word
        .duty         :byte
        ._reserved_3  :byte
    ]
    ._reserved_28[               // reserved
        .freq         :word
        .duty         :byte
        ._reserved_3  :byte
    ]
    ._reserved_2C[               // reserved
        .freq         :word
        .duty         :byte
        ._reserved_3  :byte
    ]

    .planes       :byte          // [TTTTEEEE] EEEE - enable bits, TTTT - type (0 bckgnd, 1 sprite)
    .back_color   :byte
    ._reserved_32 :byte [(8-2)]  // reserved
    .offset0      :word          // DisplayList or SpriteDescriptor table start
    .offset1      :word
    .offset2      :word
    .offset3      :word
    .plane0[
        .regs :byte [CGIA_PLANE_REGS_NO]
    ]
    .plane1[
        .regs :byte [CGIA_PLANE_REGS_NO]
    ]
    .plane2[
        .regs :byte [CGIA_PLANE_REGS_NO]
    ]
    .plane3[
        .regs :byte [CGIA_PLANE_REGS_NO]
    ]
] = $FF00

const CGIA_REG_INT_FLAG_VBI = %10000000
const CGIA_REG_INT_FLAG_DLI = %01000000
const CGIA_REG_INT_FLAG_RSI = %00100000

const text_mode_fg_color = 150 // 0x96
const text_mode_bg_color = 145 // 0x91

const CGIA_DL_IN_EMPTY_LINE = $00
const CGIA_DL_IN_DUPL_LINE  = $01
const CGIA_DL_IN_JUMP       = $02
const CGIA_DL_IN_LOAD_SCAN  = $03
const CGIA_DL_IN_LMS  = %00010000
const CGIA_DL_IN_LFS  = %00100000
const CGIA_DL_IN_LBS  = %01000000
const CGIA_DL_IN_LCG  = %10000000
const CGIA_DL_IN_VBL  = %10000000

const CGIA_DL_IN_MODE2      = $0A
const CGIA_DL_IN_MODE3      = $0B
const CGIA_DL_IN_MODE4      = $0C
const CGIA_DL_IN_MODE5      = $0D
const CGIA_DL_IN_MODE6      = $0E
const CGIA_DL_IN_MODE7      = $0F
