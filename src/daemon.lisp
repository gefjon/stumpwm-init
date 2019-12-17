(cl:in-package :stumpwm-init)

(define-condition child-process-exit-error (condition)
  ((process :initarg :process
            :accessor child-process-exit-error-process)
   (exit-code :initarg :code
              :accessor child-process-exit-code)))

(defun kill-process (process)
  "kill an `SB-IMPL::PROCESS'

from https://stackoverflow.com/questions/28785370/how-to-kill-process-created-by-run-process"
  (when (sb-ext:process-alive-p process)
    (sb-ext:process-kill process 9 :pid)
    (sb-ext:process-wait process)
    (sb-ext:process-close process))
  (let ((code (sb-ext:process-exit-code process)))
    (when (not (eq 0 code))
      (signal 'child-process-exit-error
              :code code
              :process process)))
  (values))

(defmacro with-process-exit-messages (command-name &rest body)
  "evaluates BODY while displaying any relevant messages about the exit of COMMA

COMMAND-NAME is shown unevaluated in printed output to the user"
  `(flet ((message-for-child-process-exit-error (condition)
            (stumpwm:message "process ~a exited abnormally with code ~x"
                             ',command-name
                             (child-process-exit-code condition))))
     (handler-bind ((child-process-exit-error #'message-for-child-process-exit-error))
       ,@body)))

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
    (let* ((daemon-process-name (alexandria:symbolicate '* (upcase command) '-daemon*))
           (command-string (format nil "~a~{ ~a~}" (downcase command) (mapcar #'downcase args)))
           (defparameter-form `(defparameter ,daemon-process-name
                                 (stumpwm:run-shell-command ,command-string)))
           (restart-command-name (alexandria:symbolicate 'restart- command))
           (defcommand-form `(defcommand ,restart-command-name () ()
                               (with-process-exit-messages ,command
                                 (kill-process ,daemon-process-name))
                               ,defparameter-form)))
      `(prog1 ,defparameter-form ,defcommand-form))))
