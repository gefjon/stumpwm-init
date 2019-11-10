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

                             (:file :theme
                                   :depends-on (:modules))

                             (:file :modeline
                                    ;; set modeline after theme,
                                    ;; because setting theme clobbers
                                    ;; the modeline.
                              :depends-on (:modules
                                           :theme))

                             (:file :frame-navigation)

                             (:file :keybindings
                              :depends-on (:frame-navigation
                                           :keybinding-macros))

                             (:file :emacs)))))

