(cl:in-package :stumpwm-init)

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
