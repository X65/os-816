.struct IOCB    ; Input/Output Control Block (8 bytes)
        device  .addr   ; Device Handler Address
        subdev  .byte   ; Subdevice Number
        status  .byte   ; Operation Status
        buffer  .faraddr; Data Buffer Address (supplied by user)
        _res    .res 1  ; Reserved
.endstruct

.segment "IOCB"
FDS:    .res (256 * .sizeof(IOCB))
