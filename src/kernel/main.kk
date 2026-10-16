import "task.kk"
import "api.kk"
import "../hw/cgia.kk"
import "../macros.kk"
import "cio.kk"
import "dbg.kk"
import "../hw/dspl.kk"
import "sched.kk"
import "../shell/main.kk"
import "sys.kk"

naked kernel_start {
    @a16 @i16 // 16 bit data and idx

    task_init
    sched_init
    sys_init
    CIO_init
    dspl_init

    // ---------------------------------------------------------------------
    // create two tasks:
    // - dummy task for preemption debugging
    // - shell task

    task_create             // new task stack pointer returned in .X
    lda #dbg_task
    sta &reg_pc,x           // .PC
    @a8 {
        stz &reg_pb,x           // .PB - override with kernel bank 0
        // set the name of task
        lda #'d'
        sta TASKS.name[0],y
        lda #'b'
        sta TASKS.name[1],y
        lda #'g'
        sta TASKS.name[2],y
        lda #0
        sta TASKS.name[3],y
        // and start the task
        lda #TASK_RUNNING
        sta TASKS.state,y       // TCB returned in y
    }

    task_create
    lda #shell_main
    sta &reg_pc,x           // .PC
    @a8 {
        stz &reg_db,x           // .DB - override with kernel bank 0
        stz &reg_pb,x           // .PB - override with kernel bank 0
        lda #'s'
        sta TASKS.name[0],y
        lda #'h'
        sta TASKS.name[1],y
        lda #0
        sta TASKS.name[2],y
        lda #TASK_RUNNING
        sta TASKS.state,y       // TCB returned in y
    }

    // Setup kernel Task (task00)
    tsc
    sta TASKS[0].sp

    // Set current task
    lda #TASKS[0]
    sta CURRENT_TASK
    sta NEXT_TASK

    @a8 @i8                 // 8-bit acc & index
    lda #CGIA_REG_INT_FLAG_VBI
    sta CGIA.int_enable     // enable NMI on VBL
    sta CGIA.int_status     // ACK if any INT is pending

    cli                     // Enable IRQ interrupts

    loop {
    } always
}
