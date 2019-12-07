(cl:in-package :stumpwm-init)

(defdaemon emacs --fg-daemon)

(defvar *swank-port* 4005)

(defcommand emacsclient-create-window (arg) ((:string "emacsclient -c "))
  (stumpwm:run-shell-command
   (concatenate 'string "emacsclient -c " arg)))

(defcommand emacsclient-eval (form) ((:string "an emacs-lisp form: "))
  (stumpwm:run-shell-command
   (format nil "emacsclient -e '~a'" form)))

(defvar *swank-port* 49152 "the port to use for swank")

(defun next-swank-port ()
  (incf *swank-port*))

(defcommand debug (&optional (port (next-swank-port))) ()
  (swank:create-server :port port)
  (emacsclient-eval (format nil "(slime-connect ~s ~a)" "localhost" port)))
