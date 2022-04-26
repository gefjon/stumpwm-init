(uiop:define-package :stumpwm-init/dracula
  (:use :cl)
  (:import-from :stumpwm-init/deftheme
   #:deftheme))
(cl:in-package :stumpwm-init/dracula)

(deftheme dracula
  (background "#282a36")
  (current-line "#44475a")
  (selection "#44475a")
  (foreground "#f8f8f8")
  (comment "#6272a4")
  (cyan "#8be9fd")
  (green "#50fa7b")
  (orange "#ffb86c")
  (pink "#ff79c6")
  (purple "#bd93f9")
  (red "#ff5555")
  (yellow "#f1fa8c"))
