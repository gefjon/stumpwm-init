(uiop:define-package :stumpwm-init/modeline
  (:use :cl :iterate)

  ;; non-importing dependencies
  (:import-from :cpu)
  (:import-from :hostname)
  (:import-from :mem)
  (:import-from :battery-portable)
  (:import-from :stumpwm)

  ;; ensure this file is loaded after theme.lisp because (for some
  ;; deeply cursed reason) setting a theme clobbers the modeline.
  (:import-from :stumpwm-init/theme)
  (:export #:enable-mode-lines #:modeline-reset-timings))
(cl:in-package :stumpwm-init/modeline)

(eval-when (:compile-toplevel :load-toplevel)
  (defstruct running-average
    (avg 0d0 :type double-float)
    (samples 0 :type fixnum)))

(declaim (type running-average
               async-mode-line-real-time
               async-mode-line-run-time))
(sb-ext:defglobal async-mode-line-real-time
    (make-running-average))
(sb-ext:defglobal async-mode-line-run-time
    (make-running-average))

(declaim (ftype (function (running-average double-float) (values double-float &optional))
                record-sample))
(defun record-sample (avg sample)
  (let* ((old-average (running-average-avg avg))
         (old-samples (running-average-samples avg)))
    (setf (running-average-avg avg)
          (/ (+ (* old-average old-samples) sample)
             (incf (running-average-samples avg))))))

(stumpwm:defcommand modeline-reset-timings () ()
  ;; cons new objects and overwrite rather than updating objects in-place to preserve atomicity
  (setf async-mode-line-real-time (make-running-average)
        async-mode-line-run-time (make-running-average)))

(declaim (ftype (function (fixnum) (values double-float &optional))
                internal-time-ms))
(defun internal-time-ms (internal-time)
  (/ (* internal-time 1000d0)
     internal-time-units-per-second))

(defun call-with-async-mode-line-timing (thunk)
  (let* ((start-real-time (get-internal-real-time))
         (start-run-time (get-internal-run-time))
         (ret (multiple-value-list (funcall thunk)))
         (end-real-time (get-internal-real-time))
         (end-run-time (get-internal-run-time))
         (elapsed-real-time (internal-time-ms (max (- end-real-time start-real-time) 0)))
         (elapsed-run-time (internal-time-ms (max (- end-run-time start-run-time) 0))))
    (record-sample async-mode-line-real-time elapsed-real-time)
    (record-sample async-mode-line-run-time elapsed-run-time)
    (values-list ret)))

(defmacro with-async-mode-line-timing (&body body)
  `(call-with-async-mode-line-timing (lambda () ,@body)))

(defun format-average-async-mode-line-time (ml)
  (declare (ignore ml))
  (format nil "ml: ~5,2f ms real ~5,2f ms run"
          (running-average-avg async-mode-line-real-time)
          (running-average-avg async-mode-line-run-time)))
(stumpwm:add-screen-mode-line-formatter #\a 'format-average-async-mode-line-time)

(sb-ext:defglobal async-mode-line-update-thread nil)

(defun thread-running-p (thread)
  (and thread (sb-thread:thread-alive-p thread)))

(defun inner-mode-line-format (ml)
  (let* ((stumpwm::*current-mode-line-formatters* stumpwm:*screen-mode-line-formatters*)
         (stumpwm::*current-mode-line-formatter-args* (list ml)))
    (stumpwm::mode-line-format-string ml)))

(defun try-formatting-mode-line (ml)
  (handler-case (inner-mode-line-format ml)
    (error (e) (format nil "mode-line formatting failed with error of class ~s: ~a"
                       (class-name (class-of e))
                       e))))

(defun redraw-async-mode-line (ml &optional force)
  "Copied from `stumpwm::redraw-mode-line', but without testing the mode-line-mode"
  (let* ((string (try-formatting-mode-line ml)))
    (when (or force (not (string= (stumpwm::mode-line-contents ml) string)))
      (setf (stumpwm::mode-line-contents ml) string)
      (stumpwm::resize-mode-line ml)
      (stumpwm::render-strings (stumpwm::mode-line-cc ml)
                               stumpwm:*mode-line-pad-x*
                               stumpwm:*mode-line-pad-y*
                               (stumpwm:split-string string (string #\Newline))
                               ()))))

(defun update-async-mode-lines ()
  (dolist (ml stumpwm::*mode-lines*)
    (when (eq (stumpwm::mode-line-mode ml) :async)
      (redraw-async-mode-line ml))))

(defun async-mode-line-update-loop ()
  (loop (with-async-mode-line-timing
          (update-async-mode-lines))
        (sb-thread:thread-yield)))

(defun kill-async-mode-line-update-thread ()
  (when (thread-running-p async-mode-line-update-thread)
    (sb-thread:terminate-thread async-mode-line-update-thread)
    (setf async-mode-line-update-thread nil)))

(defun spawn-async-mode-line-update-thread (&optional force)
  (when (thread-running-p async-mode-line-update-thread)
    (if force
        (kill-async-mode-line-update-thread)
        (return-from spawn-async-mode-line-update-thread
          async-mode-line-update-thread)))
  (setf async-mode-line-update-thread
        (sb-thread:make-thread #'async-mode-line-update-loop)))

(stumpwm:add-hook stumpwm:*start-hook* 'spawn-async-mode-line-update-thread)

(defun make-async-mode-line (screen head format)
  (let ((modeline (or (stumpwm::head-mode-line head)
                      (stumpwm::make-mode-line screen head format))))
    (setf (stumpwm::mode-line-format modeline) format
          (stumpwm::mode-line-mode modeline) :async)
    modeline))

(defparameter *hostname* (hostname::fmt-hostname nil))

(defparameter stumpwm:*time-modeline-string* "%a %e %b %k:%M:%S")
(defparameter stumpwm:*time-format-string-default* "%a %e %b %Y %k:%M:%S")

;; do not include %f, which formats frequency, because it depends on a
;; field of /proc/cpuinfo which isn't present on my laptop.
(defparameter cpu::*cpu-modeline-fmt* "%c"
  "just usage percentage")

(defparameter stumpwm:*screen-mode-line-format*
  (format nil "~a | %M | %B | %C | %d | %g | %a | %v" *hostname*)
  ;; (format nil "~a | %B | %C | %d | %g | %a | %v" *hostname*)
  "left to right, these are:
   memoized hostname, provided by `hostname'
   %M memory usage (supplied by `mem') (reads procfs)
   %B battery (supplied by `battery-portable') (reads procfs)
   %C cpu usage (supplied by `cpu') (reads procfs)
   %d date and time (uses posix `time')
   %g groups (virtual desktops)
   %a async-mode-line timings
   %v windows")

(stumpwm:defcommand enable-all-mode-lines () ()
  (dolist (screen stumpwm:*screen-list*)
    (dolist (head (stumpwm:screen-heads screen))
      (make-async-mode-line screen head stumpwm:*screen-mode-line-format*))))

(stumpwm:add-hook stumpwm:*start-hook* 'enable-all-mode-lines)
