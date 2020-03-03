(uiop:define-package :stumpwm-init/brightness
    (:mix :cl)
  (:export
   :brightness-get
   :brightness-set
   :brightness-inc
   :brightness
   :brightness-10+
   :brightness-10-
   :brightness-show)
  (:import-from :stumpwm
   :defcommand :run-shell-command))
(cl:in-package :stumpwm-init/brightness)

(deftype brightness ()
  '(integer 0 255))

(deftype brightness-delta ()
  '(integer -256 255))

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

(defcommand brightness (delta) ((:number "brightness delta: "))
  (check-type delta brightness-delta)
  (brightness-inc delta))

(defcommand brightness-10+ () ()
  (brightness-inc 10))

(defcommand brightness-10- () ()
  (brightness-inc -10))

(defcommand brightness-show () ()
  (stumpwm:message "~d" (brightness-get)))
