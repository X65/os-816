.export shell_commands, shell_find_command

.importzp shell_str_ptr
.import shell_tokens, print_string

.macpack generic
.a16
.i16
.feature string_escapes

.include "macros.inc"

CMDS_NO = 2

.zeropage
shell_token_ptr:
    .addr 0

.code
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
    cpx #CMDS_NO*2
    bne shell_find_command_loop
    _ai16
    lda #255    ; command not found
    rts

shell_command_names:
    .addr shell_command_help_str
    .addr shell_command_echo_str

shell_commands:
    .addr shell_command_help
    .addr shell_command_echo

shell_command_help_str: .asciiz "help"
shell_command_echo_str: .asciiz "echo"

shell_command_help_HDR:
    .asciiz "Available commands:\r\n"
shell_command_help_NL:
    .asciiz "\r\n"

shell_command_help:
    lda #shell_command_help_HDR
    jsr print_string
    ldx #0
:   lda shell_command_names, X
    jsr print_string
    lda #shell_command_help_NL
    jsr print_string
    inx
    inx
    cpx #CMDS_NO*2
    bne :-
    lda #0
    rts

shell_command_echo_IFS:
    .asciiz " "

shell_command_echo:
    ldx #2
:   lda shell_tokens, X
    beq :+  ; finish when nul-token found
    jsr print_string
    lda #shell_command_echo_IFS ; print the space after echo
    jsr print_string
    inx
    inx
    bra :-
:   lda #0
    rts

