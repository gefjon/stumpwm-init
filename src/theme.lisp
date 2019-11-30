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

(stumpwm:set-fg-color dracula:foreground)
(stumpwm:set-bg-color dracula:background)
(stumpwm:set-border-color dracula:current-line)
(stumpwm:set-focus-color dracula:selection)
(stumpwm:set-unfocus-color dracula:comment)

(defparameter stumpwm:*mode-line-foreground-color* dracula:foreground)
(defparameter stumpwm:*mode-line-background-color* dracula:background)
(defparameter stumpwm:*mode-line-border-color* dracula:current-line)

(stumpwm:run-shell-command "xrdb -load ~/.Xresources")

;; this is one of dracula's colors
(stumpwm:run-shell-command (format nil "xsetroot -solid ~s" dracula:background))
