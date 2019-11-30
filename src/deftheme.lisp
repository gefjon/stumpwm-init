(cl:in-package :stumpwm-init)

(defmacro defcolor (name value)
  (check-type name symbol)
  (check-type value string)
  `(define-symbol-macro ,name ,value))

(defmacro deftheme (theme-name &rest colors)
  "defines a package named THEME-NAME containing COLORS.

each of COLORS should be a tuple of (NAME VALUE), where NAME is a
`SYMBOL' and VALUE is a `STRING'. within the newly defined package,
each NAME will be bound as a symbol macro to VALUE.

e.g.:
(deftheme MY-THEME
  (MY-COLOR \"#ffffff\"))
then, in another file:
MY-THEME:MY-COLOR => \"#ffffff\"
"
  (check-type theme-name symbol)
  (labels ((color-symbol-name (color)
             (symbol-name (first color)))
           (ensure-package ()
             (uiop:ensure-package (symbol-name theme-name)
                                  :export (mapcar #'color-symbol-name colors)))
           (color-symbol (color)
             (intern (color-symbol-name color) (ensure-package)))
           (color-value (color)
             (second color))
           (defcolor-form (color)
             `(defcolor ,(color-symbol color)
                  ,(color-value color))))
    `(progn
       ;; i'm not sure why, but emitting a `DEFPACKAGE' form seems
       ;; necessary, in addition to repeatedly evaluating
       ;; `ensure-package' during macroexpansion.
       (defpackage ,(symbol-name theme-name)
         (:export ,@(mapcar #'color-symbol-name colors)))
       ,@(mapcar #'defcolor-form colors))))
