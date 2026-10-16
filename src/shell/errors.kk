import "print.kk"

const ERRNO_MAX = 16

func shell_error @a16 @i16 {
    cmp #ERRNO_MAX
    >= {
        lda #0  // set error number to 0
    } // skip if error number is less than ERRNO_MAX
    asl A   // multiply error number by 2
    tax
    lda errno_strings,x
    print_string
}

segment RODATA
data errno_strings {
    word str_EUNKNOWN str_ENOENT str_ESRCH str_ENXIO
    word str_E2BIG str_EBADF str_EAGAIN str_ENOMEM
    word str_EBUSY str_EEXIST str_ENODEV str_ENOTDIR
    word str_EISDIR str_EINVAL str_ENFILE str_EMFILE
}

data {
    str_EUNKNOWN: "Unknown" 0
    str_ENOENT:   "No such file or directory" 0
    str_ESRCH:    "No such process" 0
    str_ENXIO:    "No such device or address" 0
    str_E2BIG:    "Argument list too long" 0
    str_EBADF:    "Bad file number" 0
    str_EAGAIN:   "Try again" 0
    str_ENOMEM:   "Out of memory" 0
    str_EBUSY:    "Device or resource busy" 0
    str_EEXIST:   "File exists" 0
    str_ENODEV:   "No such device" 0
    str_ENOTDIR:  "Not a directory" 0
    str_EISDIR:   "Is a directory" 0
    str_EINVAL:   "Invalid argument" 0
    str_ENFILE:   "File table overflow" 0
    str_EMFILE:   "Too many open files" 0
}
