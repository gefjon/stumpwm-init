(in-package :stumpwm-init)

(defcommand reboot () ()
  (stumpwm:run-shell-command "reboot"))
