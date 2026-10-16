// The shell is a simple REPL (Read Eval Print Loop) that reads a line from the console,
// tokenizes it, and then looks up the command in a table of commands.
// If the command is found it is executed.

import "../macros.kk"
import "../errors.kk"
import "../kernel/api.kk"
import "cmds.kk"
import "errors.kk"
import "print.kk"

segment RODATA
data shell_task_name {
    "shell" 0
}

// Main entry point for the shell
segment CODE
naked shell_main {
    @a16 @i16       // 16 bit data and idx

    per shell_task_name
    lda #TASK_SET_NAME
    cop #$21

    // Close STDIN/OUT/ERR (just in case...)
    pea #0
    lda #IO_CLOSE
    cop #$21
    pea #1
    lda #IO_CLOSE
    cop #$21
    pea #2
    lda #IO_CLOSE
    cop #$21

    // Open S: device and use obtained FD as STDIN/OUT/ERR
    pea #'S'                // S0: LSB - device; HSB - subdevice no
    pea #$0000              // no path
    lda #IO_OPEN
    cop #$21

    pea #0                  // assume that above code worked and returned in FD#0
    pea #1                  // duplicate as FD#1 (stdout)
    lda #IO_DUP
    cop #$21

    pea #0
    pea #2                  // duplicate as FD#2 (stderr)
    lda #IO_DUP
    cop #$21

    // REPL: Read Eval Print Loop
    loop {
        pea #4
        pea #shell_prompt
        lda #CON_WRITE
        cop #$21

        shell_read_line
        != {
            shell_error
            repeat
        } // if no error
        shell_eval
        != {
            shell_error
        } // if no error
    } always
}

data shell_prompt {
    $0D $0A "> "
}

var shell_command_buffer[256]
data shell_command_buffer_used {
    word 0
}

func shell_read_line @a16 @i16 {
    // Read a line from the console
    // and store it in the buffer
    lda #0
    sta shell_command_buffer_used
.shell_read_line_loop:
    @a16        // .A 16 bit (it might be set to 8 in following code)
    lda #256
    sec
    sbc shell_command_buffer_used
    pha
    lda shell_command_buffer_used
    clc
    adc #shell_command_buffer
    tax                     // store for echo later
    pha
    lda #CON_READ
    cop #$21
    tay                     // store for CR seek later
    pha                     // will echo to console
    clc
    adc shell_command_buffer_used
    sta shell_command_buffer_used
    phx
    lda #CON_WRITE
    cop #$21
    lda shell_command_buffer_used
    cmp #256                // check if buffer is full
    >=0 {
        lda #E2BIG
        rts
    }
    // .X still contains start of the buffer read
    // .Y contains the length of the buffer read
    @a8
    cpy #0                  // are there characters to check
    loop {
        beq .shell_read_line_loop
        lda abs $0000,x
        cmp #$0D                // check for CR
        == break
        inx
        dey
    } always
    stz abs $0000,x         // replace CR with nul-terminator
    @a16
    lda #EOK
}

func shell_eval @a16 @i16 {
    shell_tokenize_buffer
    shell_find_command      // returns doubled command index in X
    != {
        lda #ENOENT
        rts
    } // or error code in A
    jsr (shell_commands,x)
}

const TOKENS_NO = 16
var shell_tokens[TOKENS_NO * 2]

func shell_tokenize_buffer @a16 {
    // Tokenize the buffer
    @i8
    lda #shell_command_buffer
    dec A                   // point before first character
    sta shell_str_ptr
    ldx #0                  // token index
    ldy #0                  // in-token flag
    loop {
        @a16
        inc shell_str_ptr       // move to next character
        @a8
        lda (shell_str_ptr)
        == {
            break // found nul-terminator - exit
        }
        cmp #' '
        == {
            lda #0
            sta (shell_str_ptr)     // replace space with nul-terminator
            ldy #0                  // not in-token anymore
            repeat
        }
        cpy #0
        != repeat // in-token character found - move to next
        iny                     // start of token - set in-token flag
        @a16
        lda shell_str_ptr       // store the token start address
        sta shell_tokens,x
        inx
        inx
        cpx #(TOKENS_NO-1)*2    // max of 16 tokens (including nul-termination)
    } while !=
    @a16 @i16               // restore regs to 16 bit before returning
    stz shell_tokens,x      // nul-terminate the tokens
}
