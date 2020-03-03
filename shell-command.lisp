(uiop:define-package :stumpwm-init/shell-command
    (:mix :cl)
  (:export :upcase :downcase))
(cl:in-package :stumpwm-init/shell-command)

(defun coerce-string (symbol-or-string)
         (etypecase symbol-or-string
           (symbol (symbol-name symbol-or-string))
           (string symbol-or-string)))

(defun upcase (symbol-or-string)
  (string-upcase (coerce-string symbol-or-string)))

(defun downcase (symbol-or-string)
  (string-downcase (coerce-string symbol-or-string)))
