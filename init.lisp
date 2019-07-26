(cl:defpackage :stumpwm-init
	       (:use :cl :stumpwm :iterate))
(cl:in-package :stumpwm-init)

(set-prefix-key (kbd "s-x"))

(define-key *top-map* (kbd "s-;") "colon")

(defvar *swank-port* 4005)

(defcommand run-slime () ()
  (let ((port (incf *swank-port*)))
    (and (swank:create-server :port port)
         (run-shell-command (format nil "emacsclient -c --eval '(slime-connect \"localhost\" ~d)" port)))))

(defvar *launcher-map* (make-sparse-keymap))
(define-key *top-map* (kbd "s-l") *launcher-map*)

(defmacro windowed-app-launcher (program key &key (upcase-to-force t) command-line-args class)
  (check-type program symbol)
  (let* ((program-name (string-downcase (symbol-name program)))
         (define-key-form `(define-key *launcher-map* (kbd ,key) ,program-name))
         (command-line-command  (concatenate 'string
                                             program-name
                                             " "
                                             command-line-args))
         (define-forced-form `(define-key *launcher-map* (kbd ,(string-upcase key))
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

(defmacro s-x (key command)
  `(define-key *root-map* (kbd ,key) ,command))

(s-x "0" "remove-split")
(s-x "1" "only")
(s-x "2" "vsplit")
(s-x "3" "hsplit")

(defun find-successor (elt list &optional (test #'eq))
  "searches LIST for ELT, comparing by TEST, and returns the next one.
   returns NIL if ELT is not in LIST.
    wraps around to return (CAR LIST) if ELT is the last element of LIST."
  (iterate (for sublist on list)
           (when (funcall test elt (first sublist))
             (return (or (second sublist)
                         (first list))))))

(defcommand next-frame () ()
  (let* ((group (current-group))
         (current-frame (stumpwm::tile-group-current-frame group))
         (new-frame (find-successor current-frame
                                    (stumpwm::group-frames group))))
    (stumpwm::focus-frame group new-frame)))

(defcommand previous-frame () ()
  (let* ((group (current-group))
         (current-frame (stumpwm::tile-group-current-frame group))
         (list-to-search (reverse (stumpwm::group-frames group)))
         (new-frame (find-successor current-frame list-to-search)))
    (stumpwm::focus-frame group new-frame)))

(defmacro s- (key command)
  `(define-key *top-map* (kbd ,(concat "s-" key))
     ,command))

(s- "n" "next-frame")
(s- "p" "previous-frame")
