(uiop:define-package :stumpwm-init/systemd
  (:use :cl)
  (:import-from :stumpwm-init/shell-command
   #:downcase)
  (:export #:systemctl))
(cl:in-package :stumpwm-init/systemd)

(defmacro systemctl (&rest args)
  `(sb-ext:run-program "systemctl" ',(mapcar #'downcase args)
                       :search t
                       :external-format :utf-8
                       :wait nil
                       :output :stream
                       :input nil
                       :error :stream))
