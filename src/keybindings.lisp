(cl:in-package :stumpwm-init)

(set-prefix-key (kbd "s-C-x"))

;;; s-
(s- "n" "next-frame")
(s- "N" "move-window-next-frame")
(s- "p" "previous-frame")
(s- "P" "move-window-previous-frame")
(s- ";" "colon")
(s- ":" "eval")

;;; s-l
(windowed-app-launcher firefox "f")
(windowed-app-launcher wireshark "w")
(windowed-app-launcher spotify "p")
(windowed-app-launcher steam "s")
(windowed-app-launcher discord "d")
(windowed-app-launcher emacsclient "e" :command-line-args "-c"
                                       :class "Emacs")
(windowed-app-launcher google-chrome "c")
(windowed-app-launcher xterm "t")

;;; s-x
(s-x "k" "delete")
(s-x "K" "kill")
(s-x "0" "remove-split")
(s-x "1" "only")
(s-x "2" "vsplit")
(s-x "3" "hsplit")
