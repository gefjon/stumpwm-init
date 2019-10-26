;; ensure this file is loaded after theme.lisp because (for some
;; deeply cursed reason) setting a theme clobbers the modeline.

(cl:in-package :stumpwm-init)

(load-module "hostname")
(load-module "mem")
(load-module "wifi")

(defparameter *modeline-format-string*
  "%h | %g | %d | %I | %M | %v"
  "left to right, these are:
   %h hostname (supplied by hostname)
   %g groups (virtual desktops)
   %d date and time
   %I wifi link (seems broken with netplan on ubuntu 19.10; supplied by wifi)
   %M memory usage (supplied by mem)
   %v windows")

(stumpwm:enable-mode-line (stumpwm:current-screen)
                          (stumpwm:current-head)
                          t
                          *modeline-format-string*)
