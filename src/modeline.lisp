(cl:in-package :stumpwm-init)

(load-module "hostname")
(load-module "mem")
(load-module "wifi")

(stumpwm:enable-mode-line (stumpwm:current-screen)
                          (stumpwm:current-head)
                          t
                          "%h | %g | %d | %I | %M | %v"
                          ;;"^[^B^7*%h^] | %I | %M | %n | ^B%w^b | %I"
                          )
