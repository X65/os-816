import "task.kk"
import "isr.kk"

func sched_init @a16 {
    // Set NMI vector
    lda #NMI_ISR
    sta $ffea           // Native NMI vector
}

func Sched_uler @a16 {
    lda #TASKS[1]
    cmp CURRENT_TASK
    != {
        sta NEXT_TASK
        rts
    }
    lda #TASKS[2]
    sta NEXT_TASK
}
