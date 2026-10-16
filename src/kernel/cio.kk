import "api.kk"
import "task.kk"
import "../dev/dev.kk"
import "../errors.kk"
import "../macros.kk"
import "../dev/init.kk"
import "sys.kk"
import "../generic.kk"

// Central Input/Output Control Block (8 bytes)
abstract var CIOCB[
    .device :word           // Device Handler Address
    .subdev :byte           // Subdevice Number
    .status :byte           // Operation Status
    .buffer :far            // Data Buffer Address (supplied by user)
    ._res   :byte [1]       // Reserved
]

const MAX_CIOCB = 256

segment CIOCB
var CIOCBS[
    .device :word           // Device Handler Address
    .subdev :byte           // Subdevice Number
    .status :byte           // Operation Status
    .buffer :far            // Data Buffer Address (supplied by user)
    ._res   :byte [1]       // Reserved
] * 256

segment CODE
func CIO_init @a16 @i16 {
    //
    stz CIOCBS
    // clear CIO control blocks
    ldx #CIOCBS
    ldy #CIOCBS+2
    lda #MAX_CIOCB * CIOCB:sizeof - 3
    mvn 0,0

    // TODO: fill #0 with "invalid descriptor" device

    // Call every handler init()
    ldy #0
    loop {
        @a8 {
            lda dev_handlers_tab,y  // load handler letter or NUL if end of table
        }
        == break               // exit when reached end of dev_handlers_tab marker
        iny                     // move to point to handler's procedures table
        lda dev_handlers_tab,y  // load dev handlers table address
        add #DEV_HANDLER.init:offsetof // add init function offset
        tax
        jsr ($0000,x)           // JSR to init procedure
        iny
        iny                     // move over address to next entry
    } always
}

//
//    user stack frame...
//
const path    =s_regsf+1        // buffer pointer
const device  =path+2           // High byte - subdevice no; Low byte - device letter

//
// OPEN CIOCB
//
naked CIO_open @a16 @i16 {
    // Find an available CIOCB
    ldx #0      // CIOCB index
    loop {
        lda CIOCBS,x
        beq .skip
        txa
        add #CIOCB:sizeof
        tax
        cmp #256 * CIOCB:sizeof
    } while !=   // continue searching

    lda #EMFILE // No more CIOCBs available
    jmp sys_error

.skip:  // .X contains free CIOCB index
    @a8
    // Find device letter handler
    ldy #0
    loop {
        lda dev_handlers_tab,y
        == {
            // Reached end of device table
            @a16
            lda #ENODEV
            jmp sys_error
            @a8
        }
        cmp device,s
        == break  // found device letter handler
        iny
        iny
        iny
    } always

    // .Y contains device letter handler
    xba
    sta CIOCBS.subdev,x             // save subdevice number

    stz CIOCBS.status,x             // clear status
    stz CIOCBS.buffer,x             // clear buffer address
    @a16
    stz CIOCBS.buffer+1,x           // clear buffer address

    lda dev_handlers_tab+1,y        // copy handler table address
    sta CIOCBS.device,x             // to CIOCB

    txy                     // save .X in .Y

    // Call handler's open procedure
    add #DEV_HANDLER.open:offsetof // add open function offset
    tax
    jsr ($0000,x)           // JSR to open procedure

    // Now compute the index of CIOCB
    tya     // get saved from .Y
    lsrx #3 // divide by 8

    sta reg_a,s             // overwrite .C’s stack copy
    jmp sys_success
}

// user stack frame
const fileno  =s_regsf+1 // file descriptor number

//
// CLOSE CIOCB
//
naked CIO_close @a16 @i16 {
    ldx CURRENT_TASK
    lda TCB.fds:offsetof,x

    lda #EINVAL
    jmp sys_error
}

//
// READ CIOCB
//
naked CIO_read @a16 {
    lda #EINVAL
    jmp sys_error
}

//
// WRITE CIOCB
//
naked CIO_write @a16 {
    lda #EINVAL
    jmp sys_error
}

//
// Duplicate CIOCB
//
naked CIO_dup @a16 {
    lda #EINVAL
    jmp sys_error
}
