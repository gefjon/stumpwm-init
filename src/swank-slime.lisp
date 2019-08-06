(cl:in-package :stumpwm-init)

(defvar *swank-port* 4005)

(defcommand swank (&optional (port 4005)) ()
  (swank:create-server :port port))
