
; The shell is a simple REPL (Read Eval Print Loop) that reads a line from the console,
; tokenizes it, and then looks up the command in a table of commands.
; If the command is found it is executed.

.import shell_commands, shell_find_command, shell_error
.importzp shell_str_ptr

.export shell_tokens
.export shell_main

.include "macros.inc"
.include "errors.inc"
.include "kernel/api.inc"

.macpack generic

.segment "RODATA"
shell_task_name:
    .asciiz "shell"

.code
    ; Main entry point for the shell
shell_main:
    rep #%00110000  ; 16 bit data and idx
    .a16
    .i16

    per shell_task_name
    lda #TASK_SET_NAME
    COP $21

    ; REPL: Read Eval Print Loop
shell_loop:
    pea 4
    pea shell_prompt
    lda #CON_WRITE
    cop $21

    jsr shell_read_line
    beq :+  ; if no error
    jsr shell_error
    bra shell_loop
:   jsr shell_eval
    beq :+  ; if no error
    jsr shell_error
:   bra shell_loop

shell_prompt:
    .byte $0D, $0A, "> "

shell_command_buffer:
    .res 256
shell_command_buffer_used:
    .word 0

shell_read_line:
    ; Read a line from the console
    ; and store it in the buffer
    lda #0
    sta shell_command_buffer_used
shell_read_line_loop:
    _a16        ; .A 16 bit (it might be set to 8 in following code)
    lda #256
    sec
    sbc shell_command_buffer_used
    pha
    lda shell_command_buffer_used
    clc
    adc #shell_command_buffer
    tax             ; store for echo later
    pha
    lda #CON_READ
    cop $21
    tay             ; store for CR seek later
    pha             ; will echo to console
    clc
    adc shell_command_buffer_used
    sta shell_command_buffer_used
    phx
    lda #CON_WRITE
    cop $21
    lda shell_command_buffer_used
    cmp #256    ; check if buffer is full
    bmi shell_read_line_is_done
    lda #E2BIG
    rts
shell_read_line_is_done:
    ; .X still contains start of the buffer read
    ; .Y contains the length of the buffer read
    _a8
    cpy #0      ; are there characters to check
:   beq shell_read_line_loop
    lda a:$0000,x
    cmp #$0D    ; check for CR
    beq shell_read_line_done
    inx
    dey
    bra :-
shell_read_line_done:
    stz a:$0000,x   ; replace CR with nul-terminator
    _a16
    lda #EOK
    rts

shell_eval:
    jsr shell_tokenize_buffer
    jsr shell_find_command  ; returns doubled command index in X
    beq :+                  ; or error code in A
    lda #ENOENT
    rts
:   jsr (shell_commands,x)
    rts

TOKENS_NO = 16
shell_tokens:
    .res TOKENS_NO * 2

shell_tokenize_buffer:
    ; Tokenize the buffer
    _i8
    lda #shell_command_buffer
    dec A           ; point before first character
    sta shell_str_ptr
    ldx #0          ; token index
    ldy #0          ; in-token flag
shell_tokenize_loop:
    _a16
    inc shell_str_ptr   ; move to next character
    _a8
    lda (shell_str_ptr)
    bne :+
    bra shell_tokenize_exit     ; found nul-terminator - exit
:   cmp #' '
    bne :+
    lda #0
    sta (shell_str_ptr) ; replace space with nul-terminator
    ldy #0              ; not in-token anymore
    bra shell_tokenize_loop
:   cpy #0
    bne shell_tokenize_loop ; in-token character found - move to next
    iny                 ; start of token - set in-token flag
    _a16
    lda shell_str_ptr   ; store the token start address
    sta shell_tokens,x
    inx
    inx
    cpx #(TOKENS_NO-1)*2    ; max of 16 tokens (including nul-termination)
    bne shell_tokenize_loop
shell_tokenize_exit:
    _ai16               ; restore regs to 16 bit before returning
    stz shell_tokens,x  ; nul-terminate the tokens
    rts
