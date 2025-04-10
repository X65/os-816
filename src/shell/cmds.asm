.export shell_commands, shell_find_command

.importzp shell_str_ptr
.import shell_tokens, print_string,print_char,print_hex
.import task01, task_status_symbol

.macpack generic
.a16
.i16
.feature string_escapes

.include "kernel/task.inc"
.include "macros.inc"

.zeropage
shell_token_ptr:
    .addr 0

.code
CMDS_NO = 3
CMDS_ALIAS_NO = 2

shell_command_names:
    .addr shell_command_help_str
    .addr shell_command_echo_str
    .addr shell_command_tasks_str
;   aliases
    .addr shell_command_alias_help_str
    .addr shell_command_alias_tasks_str

shell_commands:
    .addr shell_command_help
    .addr shell_command_echo
    .addr shell_command_tasks
;
    .addr shell_command_help
    .addr shell_command_tasks

shell_command_help_str:     .asciiz "help"
shell_command_echo_str:     .asciiz "echo"
shell_command_tasks_str:    .asciiz "tasks"
;
shell_command_alias_help_str:   .asciiz "?"
shell_command_alias_tasks_str:  .asciiz "ts"

; --------------------------------------------
shell_command_IFS:
    .asciiz " "
shell_command_NL:
    .asciiz "\r\n"

; --------------------------------------------
shell_find_command:
    lda shell_tokens
    sta shell_token_ptr
    _ai8
    ldx #0          ; command index
shell_find_command_loop:
    _a16
    lda shell_command_names, X
    sta shell_str_ptr
    _a8
    ldy #0          ; character index
shell_find_command_compare_chars:
    lda (shell_token_ptr), Y
    cmp (shell_str_ptr), Y
    bne shell_find_command_next     ; strings differ - try next command
    lda (shell_str_ptr), Y          ; chars match - check if command end
    beq shell_find_command_found    ; chars match and end of command token - command matched
shell_find_command_next_char:
    iny
    bra shell_find_command_compare_chars
shell_find_command_found:
    _ai16
    lda #0
    rts
    .a8
    .i8
shell_find_command_next:
    inx
    inx
    cpx #(CMDS_NO+CMDS_ALIAS_NO)*2
    bne shell_find_command_loop
    _ai16
    lda #255    ; command not found
    rts

; --------------------------------------------
; HELP
; --------------------------------------------
shell_command_help_HDR:
    .asciiz "Available commands:\r\n"

shell_command_help:
    lda #shell_command_help_HDR
    jsr print_string
    ldx #0
:   lda shell_command_names, X
    jsr print_string
    lda #shell_command_NL
    jsr print_string
    inx
    inx
    cpx #CMDS_NO*2
    bne :-
    lda #0
    rts

; --------------------------------------------
; ECHO
; --------------------------------------------
shell_command_echo:
    ldx #2
:   lda shell_tokens, X
    beq :+  ; finish when nul-token found
    jsr print_string
    lda #shell_command_IFS ; print the space after echo
    jsr print_string
    inx
    inx
    bra :-
:   lda #0
    rts

; --------------------------------------------
; TS - list tasks
; --------------------------------------------
shell_command_tasks:
    ldx #task01
    ldy #1

shell_command_tasks_loop:
    phy                     ; save task no
    _a8
    lda f:TCB::state,x      ; load task state
    beq shell_command_tasks_next
    phx                     ; save TCB pointer
    pha                     ; save task state
    _a16
    tya                     ; print task no
    jsr print_hex
    lda #shell_command_IFS  ; print the space after no
    jsr print_string

    _ai8
    plx                     ; load task state to .X
    lda f:task_status_symbol,x
    _ai16
    jsr print_char
    plx                     ; restore TCB pointer

    lda f:TCB::name,x       ; load task name address
    beq :+                  ; skip if empty

    lda #shell_command_IFS  ; print the space before name
    jsr print_string

    ; now we need to temporarily set DBR to task bank, to access its name in print_string
    phb                     ; save DBR
    _a8
    lda 2,s                 ; load task no from stack
    pha                     ; push task no on stack
    _a16
    plb                     ; pull it back to DBR
    lda f:TCB::name,x       ; load task name address
    jsr print_string
    plb                     ; restore saved DBR

:   lda #shell_command_NL
    jsr print_string

shell_command_tasks_next:
    _a16
    txa
    add #.sizeof(TCB)
    tax
    ply                     ; restore task no
    iny
    cpy #TASKS_NO
    bne shell_command_tasks_loop

    lda #0
    rts
