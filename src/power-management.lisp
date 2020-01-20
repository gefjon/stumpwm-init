(in-package :stumpwm-init)

(defcommand reboot () ()
  (stumpwm:run-shell-command "reboot"))

(defcommand shutdown () ()
  (stumpwm:run-shell-command "shutdown now"))
