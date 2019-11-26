(cl:in-package :stumpwm-init)

(defmacro defdaemon (command &rest args)
  (labels
      ((coerce-string (symbol-or-string)
         (etypecase symbol-or-string
           (symbol (symbol-name symbol-or-string))
           (string symbol-or-string)))
       (upcase (symbol-or-string)
         (string-upcase (coerce-string symbol-or-string)))
       (downcase (symbol-or-string)
         (string-downcase (coerce-string symbol-or-string))))
    `(defvar ,(alexandria:symbolicate '* (upcase command) '-daemon*)
       (stumpwm:run-shell-command
        ,(format nil "~a~{ ~a~}" (downcase command) (mapcar #'downcase args))))))
