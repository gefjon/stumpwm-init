;; ensure this file is loaded before modeline.lisp because otherwise
;; the modeline may not respect the colors bound below.

(cl:in-package :stumpwm-init)

(defparameter stumpwm:*colors* (list dracula:background
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
(stumpwm:set-fg-color dracula:foreground)
;; `stumpwm:set-bg-color' controls the background in the message and input bar
(stumpwm:set-bg-color dracula:background)
;; `stumpwm:set-border-color' controls the border of the message and input bar
(stumpwm:set-border-color dracula:comment)

;;; window borders
;; `stumpwm:set-focus-color' applies to the border of the focused window
(stumpwm:set-focus-color dracula:comment)
;; `stumpwm:set-unfocus-color' applies to the border of non-focused windows
(stumpwm:set-unfocus-color dracula:background)

(stumpwm:update-color-map (stumpwm:current-screen))

(defparameter stumpwm:*mode-line-foreground-color* dracula:foreground)
(defparameter stumpwm:*mode-line-background-color* dracula:background)
(defparameter stumpwm:*mode-line-border-color* dracula:current-line)

(stumpwm:run-shell-command "xrdb -load ~/.Xresources")

(stumpwm:run-shell-command (format nil "xsetroot -solid ~s" dracula:background))
