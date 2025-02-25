.struct TCB     ; Task Control Block (16 bytes)
        sp      .addr   ; Stack Pointer (SP)
        _res    .byte 14
.endstruct

TASKS_NO = 32
