// CGIA - Color Graphic Interface Adaptor
// mirrors firmware/src/south/cgia/cgia.h

const CGIA_COLUMN_PX = 8

const CGIA_DL_MODE_BIT         = %00001000
const CGIA_DL_DOUBLE_WIDTH_BIT = %00010000
const CGIA_DL_MULTICOLOR_BIT   = %00100000
const CGIA_DL_DLI_BIT          = %10000000

const CGIA_PLANE_REGS_NO = 16

abstract var CGIA_PLANE_REGS[
    .regs :byte [CGIA_PLANE_REGS_NO]
]

const CGIA_PLANES                 = 4
const CGIA_AFFINE_FRACTIONAL_BITS = 8
const CGIA_MAX_DL_INSTR_PER_LINE  = 32

// plane flags
const PLANE_MASK_TRANSPARENT        = %00000001
const PLANE_MASK_BORDER_TRANSPARENT = %00001000
const PLANE_MASK_DOUBLE_WIDTH       = %00010000
const PLANE_MASK_MULTICOLOR         = %00100000
const PLANE_MASK_PIXEL_BITS         = %11000000

const PLANE_BITS_1BPP = %00000000
const PLANE_BITS_2BPP = %01000000
const PLANE_BITS_3BPP = %10000000
const PLANE_BITS_4BPP = %11000000   // 8 colors + half-bright

abstract var CGIA_PLANE_BCKGND[
    .flags          :byte
    .border_columns :byte
    .row_height     :byte
    .stride         :byte
    .scroll_x       :byte
    .offset_x       :byte
    .scroll_y       :byte
    .offset_y       :byte
    .color          :byte [8]
]

abstract var CGIA_PLANE_HAM[
    .flags          :byte
    .border_columns :byte
    .row_height     :byte
    ._reserved      :byte [5]
    .color          :byte [8]
]

abstract var CGIA_PLANE_AFFINE[
    .flags          :byte
    .border_columns :byte
    .row_height     :byte
    .texture_bits   :byte           // [xHHHxWWW] 0..7 => 2..256 px
    .u              :word
    .v              :word
    .du             :word
    .dv             :word
    .dx             :word
    .dy             :word
]

abstract var CGIA_PLANE_SPRITE[
    .active         :byte           // bitmask of active sprites
    .border_columns :byte
    .start_y        :byte
    .stop_y         :byte
    ._reserved      :byte [4]
    .color          :byte [8]       // shared by every sprite on the plane
]

var CGIA[
    .mode         :byte
    .bckgnd_bank  :byte
    .sprite_bank  :byte
    ._reserved_3  :byte [(16-3)] // reserved

    .raster       :word
    ._reserved_12 :byte [(8-2)]  // reserved
    .int_raster   :word
    .int_enable   :byte          // [VBI DLI RSI x x x x x]
    .int_status   :byte          // [VBI DLI RSI x x x x x]
    ._reserved_1C :byte [(8-4)]  // reserved

    ._reserved_20 :byte [16]     // reserved

    .planes       :byte          // [TTTTEEEE] EEEE - enable bits, TTTT - type (0 bckgnd, 1 sprite)
    .order        :byte          // plane order permutation - SJT ordering
    ._reserved_32 :byte [(4-2)]  // reserved
    .back_color   :byte
    ._reserved_35 :byte [(4-1)]  // reserved
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

const CGIA_MODE_HIRES_BIT     = %00000001 // 96 columns (768px horz) mode
const CGIA_MODE_INTERLACE_BIT = %00000010 // interlace (480px vert) mode

const CGIA_REG_INT_FLAG_VBI = %10000000
const CGIA_REG_INT_FLAG_DLI = %01000000
const CGIA_REG_INT_FLAG_RSI = %00100000

const text_mode_fg_color = 150 // 0x96
const text_mode_bg_color = 145 // 0x91

// Display List instructions
const CGIA_DL_IN_EMPTY_LINE = $00   // bits 6-4: lines count - 1
const CGIA_DL_IN_JUMP       = $02
const CGIA_DL_IN_LOAD_SCAN  = $03
const CGIA_DL_IN_LOAD_REG8  = $04   // bits 7-4: plane register index
const CGIA_DL_IN_LOAD_REG16 = $05   // bits 6-4: plane register pair index
const CGIA_DL_IN_LMS  = %00010000
const CGIA_DL_IN_LFS  = %00100000
const CGIA_DL_IN_LBS  = %01000000
const CGIA_DL_IN_LCG  = %10000000
const CGIA_DL_IN_VBL  = %10000000

// Display List mode rows
const CGIA_DL_IN_MODE0      = $08   // palette text/tile
const CGIA_DL_IN_MODE1      = $09   // palette bitmap
const CGIA_DL_IN_MODE2      = $0A   // attribute text/tile
const CGIA_DL_IN_MODE3      = $0B   // attribute bitmap
const CGIA_DL_IN_MODE6      = $0E   // Hold-and-Modify
const CGIA_DL_IN_MODE7      = $0F   // affine transform chunky pixel

// Sprite descriptor (16 bytes)
abstract var CGIA_SPRITE[
    .pos_x           :word
    .pos_y           :word
    .lines_y         :word
    .flags           :byte
    ._reserved_f     :byte
    .color           :byte [4]
    .data_offset     :word
    .next_dsc_offset :word          // reload descriptor after lines_y - sprite multiplexer
]

const CGIA_SPRITES     = 8
const SPRITE_MAX_WIDTH = 8

// sprite flags
const SPRITE_MASK_WIDTH        = %00000111  // width in 8px columns - 1
const SPRITE_MASK_DOUBLE_WIDTH = %00001000
const SPRITE_MASK_PIXEL_BITS   = %00110000
const SPRITE_MASK_MIRROR_X     = %01000000
const SPRITE_MASK_MIRROR_Y     = %10000000

const SPRITE_BITS_1BPP = %00000000
const SPRITE_BITS_2BPP = %00010000
const SPRITE_BITS_3BPP = %00100000
const SPRITE_BITS_4BPP = %00110000
