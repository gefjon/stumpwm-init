(cl:in-package :stumpwm-init)

(defvar *swank-port* 4005)

(defcommand run-slime () ()
  (let ((port (incf *swank-port*)))
    (and (swank:create-server :port port)
         (run-shell-command (format nil "emacsclient -c --eval '(slime-connect \"localhost\" ~d)" port)))))
