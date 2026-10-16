// `.macpack generic`, as `k816 convert` writes it.
//
// Neither section states a width, so each runs at the width of the place
// it is expanded into: `add #4` is a two-byte `adc` under `@a8` and a
// three-byte one under `@a16`.

inline add (#value) {
    clc
    adc #value
}

inline sub (#value) {
    sec
    sbc #value
}
