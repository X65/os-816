// Debugging utilities
//

import "api.kk"
import "../macros.kk"

//
// Simple counter running in own context
// Demonstrates that A register is preserved
//
naked dbg_task {
    @a16 @i16           // 16-bit acc & index
    // ---- main ------------------------------------------

    lda #$01
    loop {
        inc A
        sta $82
    } always
}
