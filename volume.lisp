(uiop:define-package :stumpwm-init/volume
  (:use :cl :iterate)
  (:export #:adjust-volume #:set-volume #:toggle-mute #:mute #:unmute #:volume-10+ #:volume-10-)
  (:import-from :stumpwm-init/shell-command
   #:collect-process-output-to-string #:collect-process-error-to-string)
  (:import-from :stumpwm
   #:defcommand #:message))
(cl:in-package :stumpwm-init/volume)

(defun program-exists-p (name)
  (handler-case (sb-ext:run-program name '("--version")
                                    :search t
                                    :wait t
                                    :output nil
                                    :error nil
                                    :input nil)
    (error (e) (declare (ignorable e)) nil)
    (:no-error (proc) (declare (ignorable proc)) t)))

(defparameter *pamixer-program*
  (find-if #'program-exists-p '("pamixer")))

(defparameter *pulsemixer-program*
  (find-if #'program-exists-p '("pulsemixer")))

(declaim (ftype (function (string &rest string) (values string &optional))
                run-program-return-error-or-output))
(defun run-program-return-error-or-output (program &rest args)
  (let* ((process (sb-ext:run-program program args
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

(declaim (ftype (function (&rest string) (values string &optional))
                 pamixer))
(defun pamixer (&rest args)
  (if *pamixer-program* 
      (apply #'run-program-return-error-or-output *pamixer-program* args)
      (error "pamixer not installed")))

(declaim (ftype (function (&rest string) (values string &optional))
                pulsemixer))
(defun pulsemixer (&rest args)
  (if *pulsemixer-program*
      (apply #'run-program-return-error-or-output *pulsemixer-program* args)
      (error "pulsemixer not installed")))

(defun mixerp (mixer)
  (ecase mixer
    ((pulse pulsemixer) (not (not *pulsemixer-program*)))
    ((pa pamixer) (not (not *pamixer-program*)))))

(defun call-mixer-program-case (alist)
  (iter (for (mixer . func) in alist)
    (when (mixerp mixer) (return (funcall func)))
    (finally (error "No applicable mixer found"))))

(defmacro mixer-case (&body clauses)
  (flet ((transform-clause (clause)
           (destructuring-bind (mixer &body then) clause
             `(cons ',mixer (lambda () ,@then)))))
    `(call-mixer-program-case (list ,@(mapcar #'transform-clause clauses)))))

(defcommand show-volume () ()
  (message "~a" (mixer-case
                  (pamixer (pamixer "--get-volume-human"))
                  (pulsemixer (pulsemixer "--get-volume"))))
  (values))

(declaim (ftype (function (unsigned-byte) (values string &optional))
                 increase-volume decrease-volume))
(defun increase-volume (delta)
  (mixer-case 
    (pamixer (pamixer "--increase" (prin1-to-string delta) "--allow-boost"))
    (pulsemixer (pulsemixer "--change-volume" (concatenate 'string "+" (prin1-to-string delta))))))
(defun decrease-volume (delta)
  (mixer-case 
    (pamixer (pamixer "--decrease" (prin1-to-string delta) "--allow-boost"))
    (pulsemixer (pulsemixer "--change-volume" (concatenate 'string "-" (prin1-to-string delta))))))

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
  (mixer-case
    (pamixer (pamixer "--set-volume" (prin1-to-string target) "--allow-boost"))
    (pulsemixer (pulsemixer "--set-volume" (prin1-to-string target))))
  (show-volume))

(defcommand toggle-mute () ()
  (mixer-case
    (pamixer (pamixer "--toggle-mute"))
    (pulsemixer (pulsemixer "--toggle-mute")))
  (show-volume))

(defcommand mute () ()
  (mixer-case 
    (pamixer (pamixer "--mute"))
    (pulsemixer (pulsemixer "--mute")))
  (show-volume))

(defcommand unmute () ()
  (mixer-case
    (pamixer (pamixer "--unmute"))
    (pulsemixer (pulsemixer "--unmute")))
  (show-volume))

(defcommand volume-10+ () ()
  (adjust-volume 10))

(defcommand volume-10- () ()
  (adjust-volume -10))
