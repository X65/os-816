import "api.kk"
import "../hw/ria.kk"
import "../macros.kk"
import "sys.kk"

//
//    user stack frame...
//
const bufptr  =s_regsf+1        // buffer pointer
const buflen  =bufptr+2         // buffer length

//
// READ from UART
//
naked UART_read @a16 @i16 {
    ldy #0                  // buffer index

    lda buflen,s            // get length
    != {

        tax                     // copy counter

        @a8
        loop {
            bit RIA.uart_rdy
            !v? break          // exit if no data pending

            lda RIA.uart_rxtx
            sta (bufptr,s),y        // store byte in buffer
            iny
            dex
        } while !=

    } // exit if no buffer space
    @a16
    tya
    jmp sys_success
}

//
// WRITE to UART
//
naked UART_write @a16 @i16 {
    ldy #0                  // buffer index

    lda buflen,s            // get length
    != {

        tax                     // byte counter

        @a8
        loop {
            bit RIA.uart_rdy
            >=0 break         // exit if no TX possible

            lda (bufptr,s),y        // load byte from buffer
            sta RIA.uart_rxtx
            iny
            dex                     // decrease byte counter
        } while !=

    } // exit if nothing to write
    @a16
    tya
    jmp sys_success
}
