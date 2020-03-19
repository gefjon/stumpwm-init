(uiop:define-package :stumpwm-init/volume
    (:mix :cl)
  (:export :adjust-volume :set-volume :toggle-mute :mute :unmute :volume-10+ :volume-10-)
  (:import-from :gefjon-utils
   :|:| :->)
  (:import-from :stumpwm-init/shell-command
   :collect-process-output-to-string :collect-process-error-to-string)
  (:import-from :stumpwm
   :defcommand :message))
(cl:in-package :stumpwm-init/volume)

(|:| #'pamixer (-> (&rest string) string))
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

(|:| #'show-volume (-> () (values &optional)))
(defcommand show-volume () ()
  (message "~a" (pamixer "--get-volume-human"))
  (values))

(|:| #'increase-volume (-> ((integer 0 100)) string))
(defun increase-volume (delta)
  (pamixer "--increase" (prin1-to-string delta)))
(|:| #'decrease-volume (-> ((integer 0 100)) string))
(defun decrease-volume (delta)
  (pamixer "--decrease" (prin1-to-string delta)))

(|:| #'adjust-volume (-> ((integer -100 100)) (values &optional)))
(defcommand adjust-volume (delta) ((:number "volume delta (%): "))
  "increase or decrease system volume by DELTA

DELTA should be an integer representing a positive or negative percentage."
  (if (< delta 0)
      (decrease-volume (abs delta))
      (increase-volume delta))
  (show-volume))

(|:| #'set-volume (-> ((integer 0 100)) (values &optional)))
(defcommand set-volume (target) ((:number "absolute volume (%): "))
  "set system volume to TARGET

TARGET should be a non-negative integer representing a percentage."
  (pamixer "--set-volume" (prin1-to-string target))
  (show-volume))

(|:| #'toggle-mute (-> () (values &optional)))
(defcommand toggle-mute () ()
  (pamixer "--toggle-mute")
  (show-volume))

(|:| #'mute (-> () (values &optional)))
(defcommand mute () ()
  (pamixer "--mute")
  (show-volume))

(|:| #'unmute (-> () (values &optional)))
(defcommand unmute () ()
  (pamixer "--unmute")
  (show-volume))

(|:| #'volume-10+ (-> () (values &optional)))
(defcommand volume-10+ () ()
  (adjust-volume 10))

(|:| #'volume-10- (-> () (values &optional)))
(defcommand volume-10- () ()
  (adjust-volume -10))
