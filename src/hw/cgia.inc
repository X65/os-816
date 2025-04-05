.define CGIA_COLUMN_PX 8

.define CGIA_DL_MODE_BIT %00001000
.define CGIA_DL_DLI_BIT  %10000000

.define CGIA_PLANE_REGS_NO 16

.struct CGIA_PLANE_REGS
    regs            .byte CGIA_PLANE_REGS_NO
.endstruct

.define CGIA_PLANES                 4
.define CGIA_AFFINE_FRACTIONAL_BITS 8
.define CGIA_MAX_DL_INSTR           32

.define PLANE_MASK_TRANSPARENT        %00000001
.define PLANE_MASK_BORDER_TRANSPARENT %00001000
.define PLANE_MASK_DOUBLE_WIDTH       %00010000

.struct CGIA_PLANE_FG
    flags           .byte
    border_columns  .byte
    row_height      .byte
    stride          .byte
    scroll_x        .byte
    offset_x        .byte
    scroll_y        .byte
    offset_y        .byte
    shared_color0   .byte
    shared_color1   .byte
.endstruct

.struct CGIA_PWM
    freq    .word
    duty    .byte
            .byte
.endstruct

.define CGIA_PWMS 2

.struct CGIA
                .org    $FF00

    mode        .byte
    bckgnd_bank .byte
    sprite_bank .byte
                .byte (16-3)    ; reserved

    raster      .word
                .byte (6)       ; reserved
    int_raster  .word
    int_enable  .byte
    int_status  .byte
                .byte (4)       ; reserved

    pwm0        .tag CGIA_PWM
    pwm1        .tag CGIA_PWM
                .tag CGIA_PWM ; reserved
                .tag CGIA_PWM ; reserved

    planes      .byte        ; [TTTTEEEE] EEEE - enable bits, TTTT - type (0 bckgnd, 1 sprite)
    back_color  .byte
                .byte (8-2)   ; reserved
    offset0     .word   ; // DisplayList or SpriteDescriptor table start
    offset1     .word
    offset2     .word
    offset3     .word
    plane0      .tag CGIA_PLANE_REGS
    plane1      .tag CGIA_PLANE_REGS
    plane2      .tag CGIA_PLANE_REGS
    plane3      .tag CGIA_PLANE_REGS
.endstruct

.define CGIA_REG_INT_FLAG_VBI %10000000
.define CGIA_REG_INT_FLAG_DLI %01000000
.define CGIA_REG_INT_FLAG_RSI %00100000

text_mode_fg_color = 150; // 0x96
text_mode_bg_color = 145; // 0x91

CGIA_DL_IN_EMPTY_LINE = $00
CGIA_DL_IN_DUPL_LINE  = $01
CGIA_DL_IN_JUMP       = $02
CGIA_DL_IN_LOAD_SCAN  = $03
CGIA_DL_IN_LMS  = %00010000
CGIA_DL_IN_LFS  = %00100000
CGIA_DL_IN_LBS  = %01000000
CGIA_DL_IN_LCG  = %10000000
CGIA_DL_IN_VBL  = %10000000

CGIA_DL_IN_MODE2      = $0A
CGIA_DL_IN_MODE3      = $0B
CGIA_DL_IN_MODE4      = $0C
CGIA_DL_IN_MODE5      = $0D
CGIA_DL_IN_MODE6      = $0E
CGIA_DL_IN_MODE7      = $0F

