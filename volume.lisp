(uiop:define-package :stumpwm-init/volume
  (:use :cl)
  (:export #:adjust-volume #:set-volume #:toggle-mute #:mute #:unmute #:volume-10+ #:volume-10-)
  (:import-from :stumpwm-init/shell-command
   #:collect-process-output-to-string #:collect-process-error-to-string)
  (:import-from :stumpwm
   #:defcommand #:message))
(cl:in-package :stumpwm-init/volume)

(declaim (ftype (function (&rest string) (values string &optional))
                 pamixer))
(defun pamixer (&rest args)
  (let* ((process (sb-ext:run-program "pamixer" args
                                     :search t
                                     :wait t
                                     :output :stream
                                     :error :stream
                                     :input nil))
         (output (collect-process-output-to-string process))
         (error (collect-process-error-to-string process)))
    (if (> (length error) 0)
        error
        output)))

(defcommand show-volume () ()
  (message "~a" (pamixer "--get-volume-human"))
  (values))

(declaim (ftype (function (unsigned-byte) (values string &optional))
                 increase-volume decrease-volume))
(defun increase-volume (delta)
  (pamixer "--increase" (prin1-to-string delta) "--allow-boost"))
(defun decrease-volume (delta)
  (pamixer "--decrease" (prin1-to-string delta) "--allow-boost"))

(defcommand adjust-volume (delta) ((:number "volume delta (%): "))
  "increase or decrease system volume by DELTA

DELTA should be an integer representing a positive or negative percentage."
  (if (< delta 0)
      (decrease-volume (abs delta))
      (increase-volume delta))
  (show-volume))

(defcommand set-volume (target) ((:number "absolute volume (%): "))
  "set system volume to TARGET

TARGET should be a non-negative integer representing a percentage."
  (pamixer "--set-volume" (prin1-to-string target) "--allow-boost")
  (show-volume))

(defcommand toggle-mute () ()
  (pamixer "--toggle-mute")
  (show-volume))

(defcommand mute () ()
  (pamixer "--mute")
  (show-volume))

(defcommand unmute () ()
  (pamixer "--unmute")
  (show-volume))

(defcommand volume-10+ () ()
  (adjust-volume 10))

(defcommand volume-10- () ()
  (adjust-volume -10))
