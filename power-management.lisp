(uiop:define-package :stumpwm-init/power-management
    (:mix :cl)
  (:import-from :stumpwm
   :defcommand
   :run-shell-command))
(in-package :stumpwm-init/power-management)

(defcommand reboot () ()
  (run-shell-command "reboot"))

(defcommand shutdown () ()
  (run-shell-command "shutdown now"))
