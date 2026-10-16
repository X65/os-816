// simple copy-value-via-accumulator helper
inline store (value, address_) {
    lda value
    sta address_
}

// helpers for setting accumulator and index registers width
// `_a8`: a width macro, written `@a8` wherever it was used
// `_a16`: a width macro, written `@a16` wherever it was used
// `_i8`: a width macro, written `@i8` wherever it was used
// `_i16`: a width macro, written `@i16` wherever it was used
// `_ai8`: a width macro, written `@a8 @i8` wherever it was used
// `_ai16`: a width macro, written `@a16 @i16` wherever it was used

// multiple shift helpers
inline lsrx (#Count) {
    lsr * Count
}
inline aslx (#Count) {
    asl * Count
}
