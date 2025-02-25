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
