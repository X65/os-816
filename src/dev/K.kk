//
// Keyboard device K:
//

func dev_K_init {
}

func dev_K_open {
}

func dev_K_close {
}

func dev_K_get {
}

func dev_K_put {
}

func dev_K_status {
}

func dev_K_special {
}

data dev_K_handler_tab {
    word dev_K_open
    word dev_K_close
    word dev_K_get
    word dev_K_put
    word dev_K_status
    word dev_K_special
    word dev_K_init
    byte 0 0
}
