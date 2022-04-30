(uiop:define-package :stumpwm-init/power-management
  (:use :cl)
  (:import-from :stumpwm-init/systemd
                #:systemctl)
  (:import-from :stumpwm
   #:defcommand
   #:run-shell-command)
  (:shadow #:sleep)
  (:export #:reboot #:shutdown #:sleep))
(in-package :stumpwm-init/power-management)

(defcommand reboot () ()
  (run-shell-command "reboot"))

(defcommand shutdown () ()
  (run-shell-command "shutdown now"))

(defcommand sleep () ()
  (systemctl suspend))
