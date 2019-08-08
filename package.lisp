(cl:defpackage :stumpwm-init
  (:use :cl :iterate)
  (:import-from :stumpwm
                :kbd
                :defcommand)
  (:export :firefox
           :previous-frame
           :wireshark
           :move-window-next-frame
           :google-chrome
           :swank
           :spotify
           :move-window-previous-frame
           :emacsclient
           :next-frame
           :steam
           :discord
           :xterm))
