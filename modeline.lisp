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
  (:export #:enable-mode-lines))
(cl:in-package :stumpwm-init/modeline)

(defun make-ringbuffer (capacity &key (element-type t) (initial-element 0))
  (make-array capacity
              :element-type element-type
              :initial-element initial-element
              :fill-pointer 0))

(declaim (inline ringbuffer-push))
(defun ringbuffer-push (rb new-elt)
  (when (= (fill-pointer rb) (array-dimension rb 0))
    (setf (fill-pointer rb) 0))
  (vector-push new-elt rb))

(declaim (type (and (vector fixnum) (not simple-array))
               async-mode-line-timings))
(sb-ext:defglobal async-mode-line-timings
    (make-ringbuffer 128 :element-type 'fixnum))

(defun call-with-async-mode-line-timing (thunk)
  (let* ((start-time (get-internal-real-time))
         (ret (multiple-value-list (funcall thunk)))
         (end-time (get-internal-real-time))
         (elapsed-time (max (- end-time start-time) 0)))
    (ringbuffer-push async-mode-line-timings elapsed-time)
    (values-list ret)))

(defmacro with-async-mode-line-timing (&body body)
  `(call-with-async-mode-line-timing (lambda () ,@body)))

(declaim (ftype (function () (values fixnum &optional))
                total-recent-async-mode-line-times))
(defun total-recent-async-mode-line-times ()
  (iter (declare (declare-variables))
    (for idx from 0 below (array-dimension async-mode-line-timings 0))
    (for timing = (aref async-mode-line-timings idx))
    (summing timing into total)
    (declare (fixnum total))
    (finally (return total))))

(defun average-async-mode-line-time-ms ()
  (* (/ (coerce (total-recent-async-mode-line-times) 'double-float)
        (coerce internal-time-units-per-second 'double-float)
        (coerce (array-dimension async-mode-line-timings 0) 'double-float))
     1000f0))

(defun format-average-async-mode-line-time (ml)
  (declare (ignore ml))
  (format nil "ml: ~4f ms" (average-async-mode-line-time-ms)))
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

(defun invalidate-mode-line-formats ()
  (clrhash async-mode-line-format-contents))

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
  (invalidate-mode-line-formats)
  (dolist (ml stumpwm::*mode-lines*)
    (when (eq (stumpwm::mode-line-mode ml) :async)
      (redraw-async-mode-line ml))))

(defun async-mode-line-update-loop ()
  (loop (with-async-mode-line-timing
          (update-async-mode-lines)
          (sb-thread:thread-yield))))

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

(defparameter stumpwm:*time-modeline-string* "%a %e %b %k:%M:%S")
(defparameter stumpwm:*time-format-string-default* "%a %e %b %Y %k:%M:%S")

;; do not include %f, which formats frequency, because it depends on a
;; field of /proc/cpuinfo which isn't present on my laptop.
(defparameter cpu::*cpu-modeline-fmt* "%c"
  "just usage percentage")

(defparameter stumpwm:*screen-mode-line-format*
  "%h | %M | %B | %C | %d | %g | %a | %v"
  "left to right, these are:
   %h hostname (supplied by `hostname')
   %M memory usage (supplied by `mem')
   %B battery (supplied by `battery-portable')
   %C cpu usage (supplied by `cpu')
   %d date and time
   %g groups (virtual desktops)
   %a async-mode-line timings
   %v windows")

(stumpwm:defcommand enable-all-mode-lines () ()
  (dolist (screen stumpwm:*screen-list*)
    (dolist (head (stumpwm:screen-heads screen))
      (make-async-mode-line screen head stumpwm:*screen-mode-line-format*))))

(stumpwm:add-hook stumpwm:*start-hook* 'enable-all-mode-lines)
