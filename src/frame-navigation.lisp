(cl:in-package :stumpwm-init)

(defun find-successor (elt list &optional (test #'eq))
  "searches LIST for ELT, comparing by TEST, and returns the next one.
   returns NIL if ELT is not in LIST.
    wraps around to return (CAR LIST) if ELT is the last element of LIST."
  (check-type test function)
  (iterate (for sublist on list)
           (when (funcall test elt (first sublist))
             (return (or (second sublist)
                         (first list))))))

(defun advance-focus (&key bring-window go-backwards)
  (let* ((group (stumpwm:current-group))
         (current-frame (stumpwm::tile-group-current-frame group))
         (group-frames (stumpwm::group-frames group))
         (frames-sequence (if go-backwards (reverse group-frames) group-frames))
         (new-frame (find-successor current-frame frames-sequence))
         (window (stumpwm:current-window)))
    (if bring-window (stumpwm::pull-window window new-frame)
        (stumpwm::focus-frame group new-frame))))

(defcommand next-frame () ()
  (advance-focus))

(defcommand move-window-next-frame () ()
  (advance-focus :bring-window t))

(defcommand previous-frame () ()
  (advance-focus :go-backwards t))

(defcommand move-window-previous-frame () ()
  (advance-focus :bring-window t
                 :go-backwards t))
