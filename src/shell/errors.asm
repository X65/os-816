.export shell_error

.import print_string

.macpack generic
.a16
.i16

ERRNO_MAX = 16

shell_error:
    cmp #ERRNO_MAX
    blt :+  ; skip if error number is less than ERRNO_MAX
    lda #0  ; set error number to 0
:   asl A   ; multiply error number by 2
    tax
    lda errno_strings, X
    jsr print_string
    rts

.segment "RODATA"
errno_strings:
    .addr str_EUNKNOWN, str_ENOENT, str_ESRCH, str_ENXIO
    .addr str_E2BIG, str_EBADF, str_EAGAIN, str_ENOMEM
    .addr str_EBUSY, str_EEXIST, str_ENODEV, str_ENOTDIR
    .addr str_EISDIR, str_EINVAL, str_ENFILE, str_EMFILE

str_EUNKNOWN:   .asciiz "Unknown"
str_ENOENT:     .asciiz "No such file or directory"
str_ESRCH:      .asciiz "No such process"
str_ENXIO:      .asciiz "No such device or address"
str_E2BIG:      .asciiz "Argument list too long"
str_EBADF:      .asciiz "Bad file number"
str_EAGAIN:     .asciiz "Try again"
str_ENOMEM:     .asciiz "Out of memory"
str_EBUSY:      .asciiz "Device or resource busy"
str_EEXIST:     .asciiz "File exists"
str_ENODEV:     .asciiz "No such device"
str_ENOTDIR:    .asciiz "Not a directory"
str_EISDIR:     .asciiz "Is a directory"
str_EINVAL:     .asciiz "Invalid argument"
str_ENFILE:     .asciiz "File table overflow"
str_EMFILE:     .asciiz "Too many open files"
