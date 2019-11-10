;; ensure this file is loaded after theme.lisp because (for some
;; deeply cursed reason) setting a theme clobbers the modeline.

(cl:in-package :stumpwm-init)

(load-module "hostname")
(load-module "mem")

(defparameter *modeline-format-string*
  "%h | %M | %d | %g | %v"
  "left to right, these are:
   %h hostname (supplied by hostname)
   %M memory usage (supplied by mem)
   %d date and time
   %g groups (virtual desktops)
   %v windows")

(stumpwm:enable-mode-line (stumpwm:current-screen)
                          (stumpwm:current-head)
                          t
                          *modeline-format-string*)
