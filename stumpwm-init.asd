(defsystem "stumpwm-init"
  :name "stumpwm-init"
  :version "0.0.1"
  :author "gefjon <arthur@goldman-tribe.org>"
  :license "MIT"
  :depends-on (:alexandria
               :iterate
               :stumpwm
               :swank
               :clx-truetype)
  :components ((:file :package)
               (:module :src
                :depends-on (:package)
                :components ((:file :modules)

                             (:file :keybinding-macros)

                             (:file :deftheme)

                             (:file :dracula
                              :depends-on (:deftheme))
                             
                             (:file :theme
                              :depends-on (:dracula))

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
                              :depends-on (:daemon))))))

