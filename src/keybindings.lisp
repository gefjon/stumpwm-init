(cl:in-package :stumpwm-init)

(stumpwm:set-prefix-key (kbd "s-F11"))

(super-key-maps (*s-x-map* x)
                (*launcher-map* l)
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
(windowed-app-launcher firefox f)
(windowed-app-launcher wireshark w)
(windowed-app-launcher spotify p)
(windowed-app-launcher steam s)
(windowed-app-launcher discord d)
(windowed-app-launcher emacsclient e :command-line-args "-c"
                                     :class "Emacs")
(windowed-app-launcher google-chrome c)
(windowed-app-launcher xterm t)

;;; s-x
(s-x "k" "delete")
(s-x "K" "kill")
;; these mimic emacs' C-x 0, C-x 1, C-x 2, and C-x 3
(s-x "0" "remove-split")
(s-x "1" "only")
(s-x "2" "vsplit")
(s-x "3" "hsplit")
