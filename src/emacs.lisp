(cl:in-package :stumpwm-init)

(defvar *emacs-daemon-process* (stumpwm:run-shell-command "emacs --fg-daemon"))
