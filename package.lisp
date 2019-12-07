(cl:defpackage :stumpwm-init
  (:use :cl :iterate)
  (:import-from :stumpwm
                :kbd
                :defcommand)
  (:shadow :debug)
  (:export
   :firefox
   :previous-frame :next-frame
   :move-window-next-frame :move-window-previous-frame
   :google-chrome
   :emacsclient :emacsclient-eval :emacsclient-create-window :debug
   :xterm :nmtui :alsamixer
   :thunderbird
   :toggle-mode-line))
