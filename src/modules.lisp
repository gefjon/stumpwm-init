(cl:in-package :stumpwm-init)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (stumpwm:set-module-dir "/home/gefjon/stumpwm-contrib"))

;;; modeline stuff
;; this doesn't strictly belong here, but whatever


(load-module "hostname")
(load-module "mem")
(load-module "wifi")

(stumpwm:enable-mode-line (stumpwm:current-screen)
                          (stumpwm:current-head)
                          t
                          "%h | %g | %d | %I | %M | %v"
                          ;;"^[^B^7*%h^] | %I | %M | %n | ^B%w^b | %I"
                          )
;;; clipboard
;; define their package for them, because otherwise the package won't
;; exist at read-time when sbcl tries to read subsequent forms
;; (defpackage #:clipboard-history
;;   (:use #:cl)
;;   (:export #:clear-clipboard-history
;;            #:start-clipboard-manager
;;            #:stop-clipboard-manager
;;            #:show-clipboard-history
;;            #:*clipboard-history-max-length*))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (load-module "clipboard-history"))
(clipboard-history:start-clipboard-manager)
