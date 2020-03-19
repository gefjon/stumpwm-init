(uiop:define-package :stumpwm-init/keybindings
    (:mix :cl)
  (:import-from :stumpwm
   :set-prefix-key :kbd)
  (:import-from :stumpwm-init/keybinding-macros
   :super-key-maps
   :windowed-app-launcher
   :s-
   :s-l
   :bind)
  (:export
   :s-x
   :s-e
   :s-h
   :s-t
   :s-g
   :alsamixer
   :pavucontrol
   :nmtui
   :firefox
   :thunderbird
   :emacsclient
   :google-chrome
   :xterm
   :retroarch))
(cl:in-package :stumpwm-init/keybindings)

(set-prefix-key (kbd "s-F11"))

(super-key-maps (*s-x-map* x)
                (*emacs-map* e)
                (stumpwm:*help-map* h)
                (stumpwm:*root-map* t)
                (stumpwm:*groups-map* g))

;;; s-
;; n and p move to the next and previous group
(s- "n" "gnext")
(s- "N" "gnext-with-window")
(s- "p" "gprev")
(s- "P" "gprev-with-window")
;; f and b move forward and backward frames
(s- "f" "next-frame")
(s- "F" "move-window-next-frame")
(s- "b" "previous-frame")
(s- "B" "move-window-previous-frame")
;; tab and shift-tab switch windows within a frame
(s- "TAB" "pull-hidden-next")
;; on my laptop, shift+tab sends ISO_Left_Tab.
(s- "ISO_Left_Tab" "pull-hidden-previous")
;; this is analogous to emacs' M-x, it reads a command name from the user & runs it
(s- ";" "colon")
;; these bindings mimic emacs' M-: (eval) and M-! (run-shell-command).
(s- ":" "eval")
(s- "!" "exec")

;;; s-l
;; a for alsamixer
(windowed-app-launcher alsamixer a :xterm-wrapper t)
;; p for pavucontrol
(windowed-app-launcher pavucontrol p)
;; w for wifi
(windowed-app-launcher nmtui w :xterm-wrapper t)
;; f for firefox
(windowed-app-launcher firefox f)
;; m for mail
(windowed-app-launcher thunderbird m)
;; e for emacs
(windowed-app-launcher emacsclient e :command-line-args "-c"
                                     :class "Emacs")
;; c for chrome
(windowed-app-launcher google-chrome c)
;; t for terminal
(windowed-app-launcher xterm t)
;; r for retroarch
(windowed-app-launcher retroarch r)

;;; s-x
;; k for kill (even tho stumpwm calls it "delete" sometimes)
(s-x "k" "delete")
(s-x "K" "kill")
;; m for modeline
(s-x "m" "mode-line")
;; these mimic emacs' C-x 0, C-x 1, C-x 2, and C-x 3
(s-x "0" "remove-split")
(s-x "1" "only")
(s-x "2" "vsplit")
(s-x "3" "hsplit")

;;; s-e
(s-e "c" "emacsclient-create-window")
(s-e ";" "emacsclient-eval")
(s-e "d" "emacsclient-debug")
(s-e "s" "emacs-status")

;;; multimedia keys
(bind "XF86MonBrightnessUp" "brightness-500+")
(bind "S-XF86MonBrightnessUp" "brightness-100+")
(bind "XF86MonBrightnessDown" "brightness-500-")
(bind "S-XF86MonBrightnessDown" "brightness-100-")
