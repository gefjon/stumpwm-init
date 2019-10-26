;; ensure this file is loaded before modeline.lisp because (for some
;; deeply cursed reason) setting a theme clobbers the modeline.

(cl:in-package :stumpwm-init)

(load-module "stumpwm-base16")
(stumpwm-base16:load-theme "dracula")

(stumpwm:run-shell-command "xrdb -load ~/.Xresources")
