// SysCall implementation

import "api.kk"
import "../macros.kk"
import "cio.kk"
import "isr.kk"
import "task.kk"
import "uart.kk"

segment DATA
var SYSCALL_TASK:word
var SYSCALL_LOCK:word // two bytes, so we can use 16-bit STZ

var apioff:word // temporary store of api offset, used in stack cleanup

//
// System Call API dispatch table
// NOTE: update `maxapi` in api.inc after adding new item
//
data apidptab {
    word UART_read
    word UART_write
    word CIO_open
    word CIO_close
    word CIO_read
    word CIO_write
    word CIO_dup
    word TASK_set_name
}

//
// System Call API parameters count
//
data sparmtab {
    word 4  // UART_read
    word 4  // UART_write
    word 4  // CIO_open
    word 2  // CIO_close
    word 2  // CIO_read
    word 2  // CIO_write
    word 4  // CIO_dup
    word 2  // TASK_set_name
}

segment CODE
func sys_init @a16 {
    // Set COP vector
    lda #COP_ISR
    sta $ffe4               // Native COP vector

    stz SYSCALL_LOCK        // We are not in a syscall
}

// Exit SysCall with return value in .A
naked sys_success @a16 {
    sta reg_a,s             //overwrite .C’s stack copy
    // Flag a successful operation by clearing the carry bit in SR:
    @a8
    lda reg_sr,s            //stack copy of SR
    and #%11111110          //clear carry bit &...
    sta reg_sr,s            //rewrite
    jmp COP_EXIT
}

// Exit SysCall with error value in .A
naked sys_error @a16 {
    sta reg_a,s             //overwrite .C’s stack copy
    // Flag an error by setting the carry bit in SR:
    @a8
    lda reg_sr,s            //stack copy of SR
    ora #%00000001          //set carry bit &...
    sta reg_sr,s            //rewrite
    jmp COP_EXIT
}
