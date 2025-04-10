.struct MSG     ; Message Structure (5 bytes)
        from    .byte   ; Task Number of sending task
        type    .byte   ; Message Type
        data    .faraddr; Message Data (immediatre or address)
.endstruct

.enum
        TASK_FREE = 0
        TASK_GENESIS    ; the task is in the process of being created
        TASK_RUNNING
        TASK_STOPPED    ; not getting CPU time but still processing signals
        TASK_WAITING    ; waiting for I/O, but can still receive signals
        TASK_SIGNAL     ; processing a signal, cannot be preempted
        TASK_SINGLE     ; cannot be preempted, must yield or use a syscall to give up CPU time
.endenum

.struct TCB     ; Task Control Block (32 bytes)
        sp      .addr   ; Stack Pointer (SP)
        state   .byte   ; Task State
        signals .byte   ; Active Signals
        sigmask .byte   ; Signal Mask
        evtmask .byte   ; Kernel events mask
        sighndl .addr   ; Signal Handler Address
        message .tag MSG
        _res    .res 1  ; Reserved
        name    .addr   ; Task name address
        fds     .byte 16; Open file descriptors
.endstruct

TASKS_NO = 32
