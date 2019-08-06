(cl:in-package :stumpwm-user)
(require :asdf)
(require :quicklisp)
(push "/home/gefjon/stumpwm-contrib/" asdf:*central-registry*)

(ql:quickload :stumpwm-init)
