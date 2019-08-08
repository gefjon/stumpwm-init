(defsystem "stumpwm-init"
  :name "stumpwm-init"
  :version "0.0.1"
  :author "gefjon <arthur@goldman-tribe.org>"
  :license "MIT"
  :depends-on (:alexandria
               :iterate
               :stumpwm
               :swank)
  :pathname "src/"
  :serial t
  :components ((:file "package")
               (:file "modules")
               (:file "keybinding-macros")
               (:file "colors")
               (:file "swank-slime")
               (:file "modeline")
               (:file "frame-navigation")
               (:file "keybindings")))

