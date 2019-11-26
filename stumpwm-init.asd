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

                             (:file :daemon)
                             
                             (:file :emacs
                              :depends-on (:daemon))

                             (:file :screensaver
                              :depends-on (:daemon))))))

