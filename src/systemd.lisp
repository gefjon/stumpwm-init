(cl:in-package :stumpwm-init)

(defun coerce-string (symbol-or-string)
         (etypecase symbol-or-string
           (symbol (symbol-name symbol-or-string))
           (string symbol-or-string)))

(defun upcase (symbol-or-string)
  (string-upcase (coerce-string symbol-or-string)))

(defun downcase (symbol-or-string)
  (string-downcase (coerce-string symbol-or-string)))

(defmacro systemctl ((&rest args) &key collect-output)
  `(sb-ext:run-program "systemctl" ',(mapcar #'downcase args)
                       :search t
                       :external-format :utf-8
                       :wait nil
                       :output :stream
                       :input nil
                       :error :stream))
