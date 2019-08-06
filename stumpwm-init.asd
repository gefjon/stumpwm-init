(defsystem "stumpwm-init"
  :name "stumpwm-init"
  :version "0.0.1"
  :author "gefjon <arthur@goldman-tribe.org>"
  :license "MIT"
  :depends-on (:alexandria
               :iterate
               :stumpwm
               :swank)
  :serial t
  :components ((:file "stumpwm-init")))
