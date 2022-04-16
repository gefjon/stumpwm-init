(uiop:define-package :stumpwm-init/brightness
    (:mix :cl)
  (:export
   #:brightness-get
   #:brightness-set
   #:brightness-inc
   #:brightness-percent-inc
   #:brightness-percent
   #:brightness-5%+
   #:brightness-5%-
   #:brightness-1%+
   #:brightness-1%-
   #:brightness
   #:brightness-500+
   #:brightness-100+
   #:brightness-500-
   #:brightness-100-
   #:brightness-show)
  (:import-from :stumpwm
   :defcommand :run-shell-command))
(cl:in-package :stumpwm-init/brightness)

(deftype brightness ()
  'unsigned-byte)

(deftype brightness-percent ()
  '(integer 0 100))

(deftype brightness-delta ()
  'signed-byte)

(deftype brightness-percent-delta ()
  '(integer -100 100))

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

(declaim (ftype (function (brightness-percent-delta) (values))
                brightness-percent-inc))
(defun brightness-percent-inc (delta)
  (stumpwm:run-shell-command (format nil "brightnessctl s ~d%~c"
                                     (abs delta)
                                     (sign-of delta)))
  (values))

(defcommand brightness-show () ()
  (stumpwm:message "~d" (brightness-get)))

(defcommand brightness-percent (percent-delta) ((:number "brightness delta: "))
  (check-type percent-delta brightness-percent-delta)
  (brightness-percent-inc percent-delta)
  (brightness-show))

(defcommand brightness-5%+ () ()
  (brightness-percent 5))

(defcommand brightness-1%+ () ()
  (brightness-percent 1))

(defcommand brightness-5%- () ()
  (brightness-percent -5))

(defcommand brightness-1%- () ()
  (brightness-percent -1))

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
