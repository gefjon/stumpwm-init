(cl:defpackage :stumpwm-init
  (:use :cl :iterate)
  (:import-from :stumpwm
                :kbd
                :*top-map*
                :make-sparse-keymap
                :define-key
                :defcommand
                :set-prefix-key
                :run-shell-command
                :run-or-raise
                :current-group
                :current-window)
  (:export :run-slime
           :firefox))
(cl:in-package :stumpwm-init)

(set-prefix-key (kbd "s-C-x"))

(defmacro s- (key command)
  `(define-key *top-map* (kbd ,(concatenate 'string "s-" key))
     ,command))

(defmacro super-key-maps (&rest variables-and-keys)
  (flet ((defvar-form (map-name)
           `(defvar ,map-name (make-sparse-keymap)))
         
         (top-map-binding-form (key map-name)
           `(s- ,key ,map-name))
         
         (defun-form (key map-name)
           (let ((full-keycode  (concatenate 'string "s-" key)))
             `(defun ,(intern (string-upcase full-keycode))
                  (key command)
                (define-key ,map-name (kbd key) command)))))
    
    (cons 'progn
          (iterate (for (map-name key) in variables-and-keys)
                   (nconcing (list (defvar-form map-name)
                                   (top-map-binding-form key map-name)
                                   (defun-form key map-name)))))))

(super-key-maps (*s-x-map* "x")
                (*launcher-map* "l"))

(defvar *swank-port* 4005)

(defcommand run-slime () ()
  (let ((port (incf *swank-port*)))
    (and (swank:create-server :port port)
         (run-shell-command (format nil "emacsclient -c --eval '(slime-connect \"localhost\" ~d)" port)))))

(defmacro windowed-app-launcher (program key &key (upcase-to-force t) command-line-args class)
  (check-type program symbol)
  (let* ((program-name (string-downcase (symbol-name program)))
         (define-key-form `(s-l ,key ,program-name))
         (command-line-command  (concatenate 'string
                                             program-name
                                             " "
                                             command-line-args))
         (define-forced-form `(s-l ,(string-upcase key)
                                ,(concatenate 'string "exec " command-line-command)))
         (key-forms (if upcase-to-force (list define-key-form define-forced-form)
                        (list define-key-form)))
         (class (or class (string-capitalize program-name)))
         (defcommand-form `(defcommand ,program () ()
                             (run-or-raise ,command-line-command
                                           '(:class ,class)))))
    `(progn
       ,defcommand-form
       ,@key-forms)))

(windowed-app-launcher firefox "f")
(windowed-app-launcher wireshark "w")
(windowed-app-launcher spotify "p")
(windowed-app-launcher steam "s")
(windowed-app-launcher discord "d")
(windowed-app-launcher emacsclient "e" :command-line-args "-c"
                                       :class "Emacs")
(windowed-app-launcher google-chrome "c")
(windowed-app-launcher xterm "t")
; (define-key *root-map* (kbd "s") "run-slime")

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
  (let* ((group (current-group))
         (current-frame (stumpwm::tile-group-current-frame group))
         (group-frames (stumpwm::group-frames group))
         (frames-sequence (if go-backwards (reverse group-frames) group-frames))
         (new-frame (find-successor current-frame frames-sequence))
         (window (current-window)))
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

(s- "n" "next-frame")
(s- "N" "move-window-next-frame")
(s- "p" "previous-frame")
(s- "P" "move-window-previous-frame")
(s- ";" "colon")
(s- ":" "eval")
(s-x "k" "delete")
(s-x "K" "kill")
(s-x "0" "remove-split")
(s-x "1" "only")
(s-x "2" "vsplit")
(s-x "3" "hsplit")
