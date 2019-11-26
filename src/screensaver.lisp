(cl:in-package :stumpwm-init)

(defdaemon xscreensaver)
(defdaemon xss-lock -- xscreensaver-command --lock)
