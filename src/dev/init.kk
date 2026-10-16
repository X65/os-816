import "E.kk"
import "K.kk"
import "S.kk"

//
// Device handlers
//
data dev_handlers_tab {
    // Screen device
    byte 'S'
    word dev_S_handler_tab
    // Keyboard device
    byte 'K'
    word dev_K_handler_tab
    // Editor device
    byte 'E'
    word dev_E_handler_tab
    // End of table
    byte 0
}
