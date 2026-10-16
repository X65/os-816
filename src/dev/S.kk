//
// Screen device S:
//

func dev_S_init {
}

func dev_S_open {
}

func dev_S_close {
}

func dev_S_get {
}

func dev_S_put {
}

func dev_S_status {
}

func dev_S_special {
}

data dev_S_handler_tab {
    word dev_S_open
    word dev_S_close
    word dev_S_get
    word dev_S_put
    word dev_S_status
    word dev_S_special
    word dev_S_init
    byte 0 0
}
