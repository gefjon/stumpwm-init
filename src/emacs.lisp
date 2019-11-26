(cl:in-package :stumpwm-init)

(defdaemon emacs --fg-daemon)

(defvar *swank-port* 4005)

(defcommand swank (&optional (port 4005)) ()
  (swank:create-server :port port)
  (stumpwm:run-shell-command
   (format nil "emacsclient --eval '(slime-connect \"localhost\" ~d)'" port)))
