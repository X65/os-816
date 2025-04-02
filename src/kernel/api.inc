; http://sbc.bcstechnology.net/65c816interrupts.html#toc:access_sf_elements
;
;    register stack frame...
;
reg_y    =1                    ;16 bit .Y
reg_x    =reg_y+2              ;16 bit .X
reg_a    =reg_x+2              ;16 bit .A
reg_dp   =reg_a+2              ;16 bit DP
reg_db   =reg_dp+2             ;8 bit DB
reg_sr   =reg_db+1             ;8 bit SR
reg_pc   =reg_sr+1             ;16 bit PC
reg_pb   =reg_pc+2             ;8 bit PB
s_regsf  =reg_pb+1-reg_y       ;register stack frame size in bytes
;
;
;    library stack frame...
;
lib_rts  =reg_pb+1             ;library RTS address
;s_libsf  =lib_rts+2-lib_rts    ;library stack frame size in bytes
s_libsf  =lib_rts+0-lib_rts    ;library stack frame size in bytes (is not required)

; number of registered System Call APIs (in apidptab)
maxapi = 3

STDIN_FILENO  = 0
STDOUT_FILENO = 1
STDERR_FILENO = 2

.enum
    CON_READ  = 1
    CON_WRITE = 2
    IO_OPEN   = 3
    ; IO_CLOSE  = 2
    ; IO_READ   = 3
    ; IO_WRITE  = 4
    ; IO_SEEK   = 5
    ; IO_FLUSH  = 6
    ; IO_DELETE = 7
    ; IO_RENAME = 8
    ; IO_MKDIR  = 9
    ; IO_RMDIR  = 10
    ; IO_STAT   = 11
    ; IO_UNLINK = 12
    ; IO_CHDIR  = 13
    ; IO_GETCWD = 14
    ; IO_OPENDIR= 15
    ; IO_CLOSEDIR=16
    ; IO_READDIR= 17
    ; IO_TRUNCATE=18
    ; IO_SYNC   = 19
.endenum
