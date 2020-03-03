(uiop:define-package :stumpwm-init/emacs
    (:mix :cl)
  (:import-from :stumpwm
   :defcommand)
  (:import-from :stumpwm-init/shell-command
   :collect-process-output-to-string)
  (:import-from :stumpwm-init/systemd
   :systemctl)
  (:import-from :swank)
  (:export
   :emacsclient-create-window
   :emacsclient-eval
   :kill-emacs
   :restart-emacs
   :emacs-status
   :emacsclient-debug))
(cl:in-package :stumpwm-init/emacs)

(defcommand emacsclient-create-window (arg) ((:string "emacsclient -c "))
  (stumpwm:run-shell-command
   (concatenate 'string "emacsclient -c " arg)))

(defcommand emacsclient-eval (form) ((:string "an emacs-lisp form: "))
  (stumpwm:run-shell-command
   (format nil "emacsclient -e '~a'" form)))

(defcommand kill-emacs () ()
  (emacsclient-eval "(kill-emacs)"))

(defcommand restart-emacs () ()
  (systemctl --user restart emacs.service))

(defun emacs-daemon-status ()
  (collect-process-output-to-string
   (systemctl --user status emacs.service)))

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
