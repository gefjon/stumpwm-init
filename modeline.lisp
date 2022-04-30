(uiop:define-package :stumpwm-init/modeline
  (:use :cl)

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

(sb-ext:defglobal async-mode-line-update-thread nil)
(sb-ext:defglobal async-mode-line-format-contents (make-hash-table :test #'equal))

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

(defun get-mode-line-format (ml &aux (format-string (stumpwm::mode-line-format ml)))
  (multiple-value-bind (val presentp) (gethash format-string async-mode-line-format-contents)
    (if (and presentp val) val
        (setf (gethash format-string async-mode-line-format-contents)
              (try-formatting-mode-line ml)))))

(defun invalidate-mode-line-formats ()
  (clrhash async-mode-line-format-contents))

(defun redraw-async-mode-line (ml &optional force)
  "Copied from `stumpwm::redraw-mode-line', but without testing the mode-line-mode"
  (let* ((string (get-mode-line-format ml)))
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
  (loop (update-async-mode-lines)
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

(defparameter stumpwm:*time-modeline-string* "%a %e %b %k:%M:%S")
(defparameter stumpwm:*time-format-string-default* "%a %e %b %Y %k:%M:%S")

;; do not include %f, which formats frequency, because it depends on a
;; field of /proc/cpuinfo which isn't present on my laptop.
(defparameter cpu::*cpu-modeline-fmt* "%c"
  "just usage percentage")

(defparameter stumpwm:*screen-mode-line-format*
  "%h | %M | %B | %C | %d | %g | %v"
  "left to right, these are:
   %h hostname (supplied by `hostname')
   %M memory usage (supplied by `mem')
   %B battery (supplied by `battery-portable')
   %C cpu usage (supplied by `cpu')
   %d date and time
   %g groups (virtual desktops)
   %v windows")

(stumpwm:defcommand enable-all-mode-lines () ()
  (dolist (screen stumpwm:*screen-list*)
    (dolist (head (stumpwm:screen-heads screen))
      (make-async-mode-line screen head stumpwm:*screen-mode-line-format*))))

(stumpwm:add-hook stumpwm:*start-hook* 'enable-all-mode-lines)
