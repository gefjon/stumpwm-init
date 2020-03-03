(uiop:define-package :stumpwm-init/modeline
    (:mix :cl)
  (:import-from :cpu)
  (:import-from :hostname)
  (:import-from :mem)
  (:import-from :battery-portable)
  (:import-from :stumpwm-init/theme
                ; ensure this file is loaded after theme.lisp because
                ; (for some deeply cursed reason) setting a theme
                ; clobbers the modeline.
                ))
(cl:in-package :stumpwm-init/modeline)

(defparameter stumpwm:*time-modeline-string* "%a %e %b %k:%M:%S")
(defparameter stumpwm:*time-format-string-default* "%a %e %b %Y %k:%M:%S")

;; do not include %f, which formats frequency, because it depends on a
;; field of /proc/cpuinfo which isn't present on my laptop.
(defparameter cpu::*cpu-modeline-fmt* "%c @ %t %C"
  "from left:
%c usage percentage
%t temperature
%C usage bar graph")

(defparameter stumpwm:*screen-mode-line-format*
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
                          stumpwm:*screen-mode-line-format*)
