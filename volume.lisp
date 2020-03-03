(uiop:define-package :stumpwm-init/volume
    (:mix :cl)
  (:export :adjust-volume :set-volume :toggle-mute :mute :unmute)
  (:import-from :stumpwm
   :defcommand))
(cl:in-package :stumpwm-init/volume)

(defvar *audio-sink* 1
  "the sink used for audio output in pulseaudio.

on my laptop, sink 0 is hdmi and sink 1 is the speakers or headphones.")

(defun sink-string ()
  (prin1-to-string *audio-sink*))

(defun pactl (subcommand &rest args)
  (sb-ext:run-program "pactl" (cons subcommand args)
                      :search t
                      :wait t
                      :output nil
                      :error nil
                      :input nil))

(defcommand adjust-volume (delta) ((:number "volume delta (%): "))
  "increase or decrease system volume by DELTA

DELTA should be an integer representing a positive or negative percentage."
  (pactl "set-sink-volume" (sink-string) (format nil "~@d%" delta)))

(defcommand set-volume (target) ((:number "absolute volume (%): "))
  "set system volume to TARGET

TARGET should be a non-negative integer representing a percentage."
  (pactl "set-sink-volume" (sink-string) (prin1-to-string target)))

(defcommand toggle-mute () ()
  (pactl "set-sink-mute" (sink-string) "toggle"))

(defcommand mute () ()
  (pactl "set-sink-mute" (sink-string) "1"))

(defcommand unmute () ()
  (pactl "set-sink-mute" (sink-string) "0"))
