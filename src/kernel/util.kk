import "../macros.kk"

var dp kstrncpy_src[3]
var dp kstrncpy_dst[3]

//
// Copy `.X` non-null bytes from `kstrncpy_src` to `kstrncpy_dst`.
//
// @param {register} .A         - copy max n chars
// @param {global} kstrncpy_src - source far-address (24bit)
// @param {global} kstrncpy_dst - destination far-address (24bit)
// @modifies .A, .X, .Y
//
func kstrncpy @i16 {
    ldy #0
    tax
    != {
        @a8
        loop {
            lda [kstrncpy_src],y
            sta [kstrncpy_dst],y
            == break
            iny
            dex
        } while !=
    }
    @a16
}
