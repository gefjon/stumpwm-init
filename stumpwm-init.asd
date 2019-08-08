(defsystem "stumpwm-init"
  :name "stumpwm-init"
  :version "0.0.1"
  :author "gefjon <arthur@goldman-tribe.org>"
  :license "MIT"
  :depends-on (:alexandria
               :iterate
               :stumpwm
               :swank)
  :components ((:file :package)
               (:module :src
                        :depends-on (:package)
                        :components ((:file :modules)

                                     (:file :keybinding-macros)

                                     (:file :colors)

                                     (:file :swank-slime)

                                     (:file :modeline
                                            :depends-on (:modules))

                                     (:file :frame-navigation)

                                     (:file :keybindings
                                           :depends-on (:frame-navigation
                                                        :keybinding-macros))))))

