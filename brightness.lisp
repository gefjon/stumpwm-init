(uiop:define-package :stumpwm-init/brightness
    (:mix :cl)
  (:export
   :brightness-get
   :brightness-set
   :brightness-inc
   :brightness
   :brightness-500+
   :brightness-100+
   :brightness-500-
   :brightness-100-
   :brightness-show)
  (:import-from :stumpwm
   :defcommand :run-shell-command))
(cl:in-package :stumpwm-init/brightness)

(deftype brightness ()
  'unsigned-byte)

(deftype brightness-delta ()
  'signed-byte)

(declaim (ftype (function () brightness)
                brightness-get))
(defun brightness-get ()
  (values ;; this `VALUES' form surpresses the second value from `PARSE-INTEGER'
   (parse-integer (stumpwm:run-shell-command "brightnessctl -m g" t))))

(declaim (ftype (function (brightness) (values))
                brightness-set))
(defun brightness-set (delta)
  (stumpwm:run-shell-command (format nil "brightnessctl s ~d" delta))
  (values))

(declaim (ftype (function (fixnum) standard-char)))
(defun sign-of (n)
  (if (< n 0) #\- #\+))

(declaim (ftype (function (brightness-delta) (values))
                brightness-inc))
(defun brightness-inc (delta)
  (stumpwm:run-shell-command (format nil "brightnessctl s ~d~c"
                                     (abs delta)
                                     (sign-of delta)))
  (values))

(defcommand brightness-show () ()
  (stumpwm:message "~d" (brightness-get)))

(defcommand brightness (delta) ((:number "brightness delta: "))
  (check-type delta brightness-delta)
  (brightness-inc delta)
  (brightness-show))

(defcommand brightness-500+ () ()
  (brightness 500))

(defcommand brightness-100+ () ()
  (brightness 100))

(defcommand brightness-500- () ()
  (brightness -500))

(defcommand brightness-100- () ()
  (brightness -100))
