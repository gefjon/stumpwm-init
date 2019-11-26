;; ensure this file is loaded after theme.lisp because (for some
;; deeply cursed reason) setting a theme clobbers the modeline.

(cl:in-package :stumpwm-init)

(load-module "hostname")
(load-module "mem")
(load-module "battery-portable")
(load-module "cpu")

(defparameter stumpwm:*time-modeline-string* "%a %e %b %k:%M:%S")
(defparameter stumpwm:*time-format-string-default* "%a %e %b %Y %k:%M:%S")

(defparameter *modeline-format-string*
  "%h | %M | %B | %C | %d | %g | %v"
  "left to right, these are:
   %h hostname (supplied by `hostname')
   %M memory usage (supplied by `mem')
   %B battery (supplied by `battery-portable')
   %c cpu usage (supplied by `cpu')
   %d date and time
   %g groups (virtual desktops)
   %v windows")

(stumpwm:enable-mode-line (stumpwm:current-screen)
                          (stumpwm:current-head)
                          t
                          *modeline-format-string*)
