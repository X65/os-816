import "api.kk"
import "../macros.kk"
import "util.kk"
import "sys.kk"
import "../generic.kk"

abstract var MSG[ // Message Structure (5 bytes)
    .from :byte     // Task Number of sending task
    .type :byte     // Message Type
    .data :far      // Message Data (immediate or address)
]

const TASK_FREE = 0,
      TASK_GENESIS,   // the task is in the process of being created
      TASK_RUNNING,
      TASK_STOPPED,   // not getting CPU time but still processing signals
      TASK_WAITING,   // waiting for I/O, but can still receive signals
      TASK_SIGNAL,    // processing a signal, cannot be preempted
      TASK_SINGLE     // cannot be preempted, must yield or use a syscall to give up CPU time

abstract var TCB[ // Task Control Block (64 bytes)
    .sp      :word          // Stack Pointer (SP)
    .state   :byte          // Task State
    .signals :byte          // Active Signals
    .sigmask :byte          // Signal Mask
    .evtmask :byte          // Kernel events mask
    .sighndl :word          // Signal Handler Address
    .message[
        .from :byte     // Task Number of sending task
        .type :byte     // Message Type
        .data :far      // Message Data (immediate or address)
    ]
    ._res    :byte [23]     // Reserved
    .name    :byte [12]     // Task name
    .fds     :byte [16]     // Open file descriptors
]

const TASKS_NO = 32
const TASK_NAME_LEN = 12

segment TCB
var TASKS[
    .sp      :word          // Stack Pointer (SP)
    .state   :byte          // Task State
    .signals :byte          // Active Signals
    .sigmask :byte          // Signal Mask
    .evtmask :byte          // Kernel events mask
    .sighndl :word          // Signal Handler Address
    .message[
        .from :byte     // Task Number of sending task
        .type :byte     // Message Type
        .data :far      // Message Data (immediate or address)
    ]
    ._res    :byte [23]     // Reserved
    .name    :byte [12]     // Task name
    .fds     :byte [16]     // Open file descriptors
] * 32

segment DATA
var CURRENT_TASK:word
var NEXT_TASK:word

data task_status_symbol {
    'F'         // TASK_FREE
    'G'         // TASK_GENESIS
    'R'         // TASK_RUNNING
    'S'         // TASK_STOPPED
    'W'         // TASK_WAITING
    's'         // TASK_SIGNAL
    '1'         // TASK_SINGLE
}

segment CODE
func task_init @a16 @i16 {
    stz TASKS
    // clear tasks control blocks
    ldx #TASKS
    ldy #TASKS+2
    lda #TASKS_NO * TCB:sizeof - 3
    mvn 0,0

    stz CURRENT_TASK
    stz NEXT_TASK
}

//   Allocate a task structure for new task in scheduler.
//   Resets the task structure to GENESIS state.
//   You will need to set task start address on task stack,
//   before switching the task to RUNNING state.
// Returns:
//   @.X - task stack pointer
//   @.Y - Task Control Block pointer
func task_create @i16 {
    // find free task
    ldx #TCB:sizeof         // task 0 belongs to kernel - start from task #1
    loop {
        @a8
        lda TASKS.state,x
        beq .task_create_found  // TASK_FREE = 0 - use it
        @a16
        txa
        add #TCB:sizeof
        tax
        cmp #TASKS_NO * TCB:sizeof
    } while !=
    // no free tasks
    pla                     // restore stack to initial
    lda #$FFFF
    rts
    @a8
.task_create_found:
    inc TASKS.state,x           // move task to TASK_GENESIS state
    @a16
    txa
    asl
    asl
    asl                         // index is in .B
    ora #$FF                    // set low byte to FF
    sub #s_regsf                // will store 13 bytes of "preempted" task stack
    sta TASKS.sp,x              // save as stack-pointer
    phx                         // save TCB for later
    pha                         // save SP for later
    stz TASKS.signals,x         // zero signals & sigmask
    txa                         // now clean the rest by copying signals/sigmask
    add #TASKS.signals
    tax
    add #2
    tay
    lda #TCB:sizeof - TCB.signals:offsetof - 3
    mvn 0,0

    // now initialize the stack of "preempted" task
    // with initial registers values and RTI address of program start
    //
    pla                     // restore task stack pointer address
    tax                     // copy to .X
    stz &reg_y,x            // .Y
    stz &reg_x,x            // .X
    stz &reg_a,x            // .C
    and #$FF00              // mask to have start of task data in .C
    sta &reg_dp,x           // .DP - direct page start
    @a8 {
        xba
        sta &reg_db,x           // .DB - data bank
        sta &reg_pb,x           // .PB - program bank
        lda #$32                // initial status register
        sta &reg_sr,x           // .SR
    }
    stz &reg_pc,x           // .PC

    ply                     // restore saved TCB to y
}

// -----------------------------------------

//
//    user stack frame...
//
const nameptr =s_regsf+1        // name pointer

// SysCall to set Task name
naked TASK_set_name @a16 @i16 {
    lda nameptr,s
    sta kstrncpy_src
    phb
    @a8 {
        pla
        sta kstrncpy_src+2

        stz kstrncpy_dst+2
    }
    lda CURRENT_TASK
    add #TCB.name:offsetof  // add name offset
    sta kstrncpy_dst

    lda #TASK_NAME_LEN
    kstrncpy

    jmp sys_success
}
