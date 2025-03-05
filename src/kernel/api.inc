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
maxapi = 2
