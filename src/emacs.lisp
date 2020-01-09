(cl:in-package :stumpwm-init)

(defcommand emacsclient-create-window (arg) ((:string "emacsclient -c "))
  (stumpwm:run-shell-command
   (concatenate 'string "emacsclient -c " arg)))

(defcommand emacsclient-eval (form) ((:string "an emacs-lisp form: "))
  (stumpwm:run-shell-command
   (format nil "emacsclient -e '~a'" form)))

(defcommand kill-emacs () ()
  (emacsclient-eval "(kill-emacs)"))

(defcommand restart-emacs () ()
  (systemctl (--user restart emacs.service)))

(defun collect-process-output-to-string (process)
  (with-output-to-string (s)
    (iter
      (with stream = (sb-ext:process-output process))
      (for line = (read-line stream nil nil))
      (while line)
      (unless (first-time-p)
        (write-char #\newline s))
      (write-string line s))))

(defun emacs-daemon-status ()
  (collect-process-output-to-string
   (systemctl (--user status emacs.service))))

(defcommand emacs-status () ()
  (stumpwm:message "~a" (emacs-daemon-status)))

(defvar *swank-port* 49152 "the port to use for swank")

(defun next-swank-port ()
  (incf *swank-port*))

(defun elisp-slime-connect-form (port &optional (host "localhost"))
  (format nil "(slime-connect ~s ~a)" host port))

(defcommand emacsclient-debug (&optional (port (next-swank-port))) ()
  (swank:create-server :port port)
  (emacsclient-eval (elisp-slime-connect-form port)))
