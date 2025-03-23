.struct MSG     ; Message Structure (5 bytes)
        from    .byte   ; Task Number of sending task
        type    .byte   ; Message Type
        data    .faraddr; Message Data (immediatre or address)
.endstruct

.struct TCB     ; Task Control Block (32 bytes)
        sp      .addr   ; Stack Pointer (SP)
        state   .byte   ; Task State
        signals .byte   ; Active Signals
        sigmask .byte   ; Signal Mask
        evtmask .byte   ; Kernel events mask
        sighndl .addr   ; Signal Handler Address
        message .tag MSG
        _res    .res 3  ; Reserved
        fds     .byte 16; Open file descriptors
.endstruct

TASKS_NO = 32
