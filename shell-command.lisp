(uiop:define-package :stumpwm-init/shell-command
    (:mix :iterate :cl)
  (:export
   :upcase
   :downcase
   :collect-stream-to-string
   :collect-process-output-to-string
   :collect-process-error-to-string))
(cl:in-package :stumpwm-init/shell-command)

(defun coerce-string (symbol-or-string)
         (etypecase symbol-or-string
           (symbol (symbol-name symbol-or-string))
           (string symbol-or-string)))

(defun upcase (symbol-or-string)
  (string-upcase (coerce-string symbol-or-string)))

(defun downcase (symbol-or-string)
  (string-downcase (coerce-string symbol-or-string)))

(defun collect-stream-to-string (stream)
  (with-output-to-string (s)
    (iter
      (for line = (read-line stream nil nil))
      (while line)
      (unless (first-time-p)
        (write-char #\newline s))
      (write-string line s))))

(defun collect-process-output-to-string (process)
  (collect-stream-to-string (sb-ext:process-output process)))

(defun collect-process-error-to-string (process)
  (collect-stream-to-string (sb-ext:process-error process)))

