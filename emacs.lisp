(uiop:define-package :stumpwm-init/emacs
  (:use :cl)
  (:import-from :stumpwm
   #:defcommand)
  (:import-from :stumpwm-init/shell-command
   #:collect-process-output-to-string)
  (:import-from :stumpwm-init/systemd
   #:systemctl)
  (:import-from :slynk)
  (:export
   #:emacsclient-create-window
   #:emacsclient-eval
   #:kill-emacs
   #:restart-emacs
   #:emacs-status
   #:emacsclient-debug #:slynk))
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

(defvar *slynk-port* 49152 "the port to use for slynk")

(defun next-slynk-port ()
  (incf *slynk-port*))

(defun elisp-sly-connect-form (port &optional (host "localhost"))
  (format nil "(sly-connect ~s ~a)" host port))

(defcommand emacsclient-debug (&optional (port (next-slynk-port))) ()
  (slynk:create-server :port port)
  (emacsclient-eval (elisp-sly-connect-form port)))

(defcommand slynk (&optional (port (next-slynk-port))) ()
  (emacsclient-debug port))
