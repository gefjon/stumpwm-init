(uiop:define-package :stumpwm-init/theme
  (:use :cl)
  (:import-from :stumpwm-init/dracula)
  (:import-from :stumpwm
   #:*colors*
   #:set-fg-color
   #:set-bg-color
   #:set-border-color
   #:set-focus-color
   #:set-unfocus-color
   #:update-color-map
   #:current-screen
   #:*mode-line-foreground-color*
   #:*mode-line-background-color*
   #:*mode-line-border-color*
   #:run-shell-command))
;; ensure this file is loaded before modeline.lisp because otherwise
;; the modeline may not respect the colors bound below.

(cl:in-package :stumpwm-init/theme)

(defparameter *colors* (list dracula:background
                             dracula:red
                             dracula:green
                             dracula:yellow
                             dracula:comment
                             dracula:pink
                             dracula:cyan
                             dracula:foreground
                             dracula:selection
                             dracula:purple))

;;; message and input bar colors
;; `stumppwm:set-fg-color' controls the text in the message and input bar
(set-fg-color dracula:foreground)
;; `stumpwm:set-bg-color' controls the background in the message and input bar
(set-bg-color dracula:background)
;; `stumpwm:set-border-color' controls the border of the message and input bar
(set-border-color dracula:comment)

(run-shell-command (format nil "xsetroot -solid ~s" dracula:background))

;;; window borders
;; `stumpwm:set-focus-color' applies to the border of the focused window
(set-focus-color dracula:comment)
;; `stumpwm:set-unfocus-color' applies to the border of non-focused windows
(set-unfocus-color dracula:background)

(update-color-map (current-screen))

(defparameter *mode-line-foreground-color* dracula:foreground)
(defparameter *mode-line-background-color* dracula:background)
(defparameter *mode-line-border-color* dracula:current-line)

(run-shell-command "xrdb -load ~/.Xresources")

(run-shell-command (format nil "xsetroot -solid ~s" dracula:background))
