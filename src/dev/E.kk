//
// Editor device E:
//

func dev_E_init {
}

func dev_E_open {
}

func dev_E_close {
}

func dev_E_get {
}

func dev_E_put {
}

func dev_E_status {
}

func dev_E_special {
}

data dev_E_handler_tab {
    word dev_E_open
    word dev_E_close
    word dev_E_get
    word dev_E_put
    word dev_E_status
    word dev_E_special
    word dev_E_init
    byte 0 0
}
