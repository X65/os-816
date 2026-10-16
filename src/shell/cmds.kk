import "../kernel/task.kk"
import "../macros.kk"
import "print.kk"
import "main.kk"
import "../generic.kk"

var dp shell_token_ptr[2]

const CMDS_NO = 3
const CMDS_ALIAS_NO = 2

data shell_command_names {
    word shell_command_help_str
    word shell_command_echo_str
    word shell_command_tasks_str
    //   aliases
    word shell_command_alias_help_str
    word shell_command_alias_tasks_str
}

data shell_commands {
    word shell_command_help
    word shell_command_echo
    word shell_command_tasks
    //
    word shell_command_help
    word shell_command_tasks
}

data {
    shell_command_help_str:         "help" 0
    shell_command_echo_str:         "echo" 0
    shell_command_tasks_str:        "tasks" 0
}
//
data {
    shell_command_alias_help_str:   "?" 0
    shell_command_alias_tasks_str:  "ts" 0
}

// --------------------------------------------
data shell_command_IFS {
    " " 0
}
data shell_command_NL {
    "\r\n" 0
}

// --------------------------------------------
func shell_find_command @a16 {
    lda shell_tokens
    sta shell_token_ptr
    @a8 @i8
    ldx #0                  // command index
    loop {
        @a16 {
            lda shell_command_names,x
            sta shell_str_ptr
        }
        ldy #0                  // character index
        loop {
            lda (shell_token_ptr),y
            cmp (shell_str_ptr),y
            bne .shell_find_command_next    // strings differ - try next command
            lda (shell_str_ptr),y           // chars match - check if command end
            == break   // chars match and end of command token - command matched
.shell_find_command_next_char:
            iny
        } always
        @a16 @i16
        lda #0
        rts
        @a8
        @i8
.shell_find_command_next:
        inx
        inx
        cpx #(CMDS_NO+CMDS_ALIAS_NO)*2
    } while !=
    @a16 @i16
    lda #255                // command not found
}

// --------------------------------------------
// HELP
// --------------------------------------------
data shell_command_help_HDR {
    "Available commands:\r\n" 0
}

func shell_command_help @a16 @i16 {
    lda #shell_command_help_HDR
    print_string
    ldx #0
    loop {
        lda shell_command_names,x
        print_string
        lda #shell_command_NL
        print_string
        inx
        inx
        cpx #CMDS_NO*2
    } while !=
    lda #0
}

// --------------------------------------------
// ECHO
// --------------------------------------------
func shell_command_echo @a16 @i16 {
    ldx #2
    loop {
        lda shell_tokens,x
        == break // finish when nul-token found
        print_string
        lda #shell_command_IFS // print the space after echo
        print_string
        inx
        inx
    } always
    lda #0
}

data shell_command_tasks_header {
    "ID S NAME\r\n" 0
}

// --------------------------------------------
// TS - list tasks
// --------------------------------------------
func shell_command_tasks @a16 @i16 {
    lda #shell_command_tasks_header
    print_string

    ldx #TASKS[1]
    ldy #1

    loop {
        phy                     // save task no
        @a8
        lda far TCB.state:offsetof,x // load task state
        != {
            phx                     // save TCB pointer
            pha                     // save task state
            @a16
            tya                     // print task no
            print_hex
            lda #shell_command_IFS  // print the space after no
            print_string

            @a8 @i8 {
                plx                     // load task state to .X
                lda far task_status_symbol,x
            }
            write_char
            plx                     // restore TCB pointer

            @a8
            lda far TCB.name:offsetof,x // load task name first char
            != {

                @a16
                lda #shell_command_IFS  // print the space before name
                print_string
                shell_command_write_name

            } // skip if empty
            @a16
            lda #shell_command_NL
            print_string

        }
        @a16
        txa
        add #TCB:sizeof
        tax
        ply                     // restore task no
        iny
        cpy #TASKS_NO
    } while !=

    lda #0
}

func shell_command_write_name @i16 {
    @a8
    lda far TCB.name:offsetof + 0,x
    beq .skip
    write_char
    @a8
    lda far TCB.name:offsetof + 1,x
    beq .skip
    write_char
    @a8
    lda far TCB.name:offsetof + 2,x
    beq .skip
    write_char
    @a8
    lda far TCB.name:offsetof + 3,x
    beq .skip
    write_char
    @a8
    lda far TCB.name:offsetof + 4,x
    beq .skip
    write_char
    @a8
    lda far TCB.name:offsetof + 5,x
    beq .skip
    write_char
    @a8
    lda far TCB.name:offsetof + 6,x
    beq .skip
    write_char
    @a8
    lda far TCB.name:offsetof + 7,x
    beq .skip
    write_char
    @a8
    lda far TCB.name:offsetof + 8,x
    beq .skip
    write_char
    @a8
    lda far TCB.name:offsetof + 9,x
    beq .skip
    write_char
    @a8
    lda far TCB.name:offsetof + 10,x
    beq .skip
    write_char
    @a8
    lda far TCB.name:offsetof + 11,x
    beq .skip
    write_char
.skip:
    @a16
}
