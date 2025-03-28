.enum
    EUNKNOWN        = -1
    EOK
    ENOENT          ; No such file or directory
    ESRCH           ; No such process
    ENXIO           ; No such device or address
    E2BIG           ; Argument list too long
    EBADF           ; Bad file number
    EAGAIN          ; Try again
    ENOMEM          ; Out of memory
    EBUSY           ; Device or resource busy
    EEXIST          ; File exists
    ENODEV          ; No such device
    ENOTDIR         ; Not a directory
    EISDIR          ; Is a directory
    EINVAL          ; Invalid argument
    ENFILE          ; File table overflow
    EMFILE          ; Too many open files
    EFBIG           ; File too large
    ENOSPC          ; No space left on device
    ESPIPE          ; Illegal seek
    EROFS           ; Read-only file system
    EPIPE           ; Broken pipe
    EDOM            ; Math argument out of domain of func
    ERANGE          ; Math result not representable
    ENAMETOOLONG    ; File name too long
    ENOSYS          ; Function not implemented
    ENOTEMPTY       ; Directory not empty
    ENOMSG          ; No message of desired type
    ENOSTR          ; Device not a stream
    ENODATA         ; No data available
    ETIME           ; Timer expired
    EBADMSG         ; Not a data message
    EOVERFLOW       ; Value too large for defined data type
    EBADFD          ; File descriptor in bad state
    EILSEQ          ; Illegal byte sequence
    EMSGSIZE        ; Message too long
    ENOBUFS         ; No buffer space available
    ENOMEDIUM       ; No medium found
    EMEDIUMTYPE     ; Wrong medium type
    ECANCELED       ; Operation canceled
    EWOULDBLOCK     = EAGAIN
.endenum
