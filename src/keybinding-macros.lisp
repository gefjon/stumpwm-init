(cl:in-package :stumpwm-init)

(declaim (ftype (function (symbol) string) symbol-to-downcase-string))
(defun symbol-to-downcase-string (symbol)
  (string-downcase (symbol-name symbol)))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun norm-key (key)
    (ctypecase key
      (string key)
      (symbol (symbol-to-downcase-string key)))))

(defmacro s- (key command)
  `(stumpwm:define-key stumpwm:*top-map* (kbd ,(concatenate 'string "s-" (norm-key key)))
     ,command))

(defmacro super-key-maps (&rest variables-and-keys)
  (flet ((defvar-form (map-name)
           `(defvar ,map-name (stumpwm:make-sparse-keymap)))
         
         (top-map-binding-form (key map-name)
           `(s- ,key ,map-name))
         
         (defun-form (key map-name)
           (let ((full-keycode  (concatenate 'string "s-" (norm-key key))))
             `(defun ,(intern (string-upcase full-keycode))
                  (key command)
                (stumpwm:define-key ,map-name (kbd (norm-key key)) command)))))
    
    (cons 'progn
          (iterate (for (map-name key) in variables-and-keys)
                   (nconcing (list (defvar-form map-name)
                                   (top-map-binding-form key map-name)
                                   (defun-form key map-name)))))))

(defmacro windowed-app-launcher (program key &key (upcase-to-force t) command-line-args class)
  (check-type program symbol)
  (let* ((program-name (string-downcase (symbol-name program)))
         (normalized-key (norm-key key))
         (define-key-form `(s-l ,normalized-key ,program-name))

         (command-line-command  (concatenate 'string
                                             program-name
                                             " "
                                             command-line-args))
         (define-forced-form `(s-l ,(string-upcase normalized-key)
                                ,(concatenate 'string "exec " command-line-command)))
         (key-forms (if upcase-to-force (list define-key-form define-forced-form)
                        (list define-key-form)))
         (class (or class (string-capitalize program-name)))
         (defcommand-form `(defcommand ,program () ()
                             (stumpwm:run-or-raise ,command-line-command
                                                   '(:class ,class)))))
    `(progn
       ,defcommand-form
       ,@key-forms)))