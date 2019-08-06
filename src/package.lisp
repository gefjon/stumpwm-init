(cl:defpackage :stumpwm-init
  (:use :cl :iterate)
  (:import-from :stumpwm
                :kbd
                :*top-map*
                :make-sparse-keymap
                :define-key
                :defcommand
                :set-prefix-key
                :run-shell-command
                :run-or-raise
                :current-group
                :current-window))
