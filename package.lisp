(cl:defpackage :stumpwm-init
  (:use :cl :iterate)
  (:import-from :stumpwm
                :kbd
                :defcommand)
  (:shadow :debug)
  (:export
   :previous-frame :next-frame
   :move-window-next-frame :move-window-previous-frame
   :emacsclient :emacsclient-eval :emacsclient-create-window :debug
   :firefox :google-chrome
   :thunderbird
   :xterm :nmtui :alsamixer
   :toggle-mode-line))
