(cl:in-package :stumpwm-init)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (stumpwm:set-module-dir "~/stumpwm-contrib"))

(defmacro load-module (module)
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (stumpwm:load-module ,module)))

;;; clipboard
(load-module "clipboard-history")
(clipboard-history:start-clipboard-manager)
