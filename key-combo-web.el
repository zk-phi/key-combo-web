;; Language-specific key-combo for web-mode.

;; Requirements: web-mode, key-combo

;; (require 'key-combo-web)
;;
;; (key-combo-web-define "jsx" (kbd "<") '(" < " "<`!!'>"))
;; (key-combo-web-define "jsx" (kbd "&") '(" & " " && "))
;; (key-combo-web-define "jsx" (kbd ">") " > ")
;; (key-combo-web-define "jsx" (kbd "</") 'web-mode-element-close)
;; (key-combo-web-define "jsx-html" (kbd "<") '("<`!!'>" "&lt;" "<"))
;; (key-combo-web-define "jsx-html" (kbd ">") '("&gt;" ">"))
;; (key-combo-web-define "jsx-html" (kbd "&") '("&amp;" "&"))
;; (key-combo-web-define "css" (kbd "~") " ~ ")

(require 'web-mode)
(require 'key-combo)

(defmacro key-combo-web--flet (symb def &rest body)
  "Let SYMB's function definition be DEF while evaluating BODY."
  (declare (indent 2))
  `(unwind-protect
       (progn (fset ',symb ,def) ,@body)
     (fset ',symb ,(symbol-function symb))))

(defun key-combo-web--get-language-symbol (&optional language is-html)
  "Like `web-mode-language-at-pos' but returns a symbol like
`key-combo-jsx' instead of a string, and if the language is JSX,
check whether the position is inside a HTML part of the JSX and
if so, `key-combo-jsx-html' instead of `key-combo-jsx'."
  (setq language (or language (web-mode-language-at-pos))
        is-html  (or is-html  (and (string= language "jsx") (web-mode-jsx-is-html))))
  (if is-html 'key-combo-jsx-html (intern (concat "key-combo-" language))))

(defun key-combo-web--make-key-vector (key &optional language)
  "Like `key-combo-make-key-vector' but while in web-mode
buffers, reflect the language-at-pos."
  (vector (if (not (or (eq 'web-mode major-mode) language)) 'key-combo
            (key-combo-web--get-language-symbol language))
          (intern (concat "_" (key-description (vconcat key))))))

(defun key-combo-web-define (language key commands)
  "Like `key-combo-define' but defines a language-specific
keybind to `web-mode-map'. Language is either a string that
`web-mode-language-at-pos' returns, or `jsx-html'."
  (key-combo-web--flet key-combo-make-key-vector
      (lambda (key) (key-combo-web--make-key-vector key language))
    (key-combo-define web-mode-map key commands)))

(fset 'key-combo-make-key-vector (symbol-function 'key-combo-web--make-key-vector))

(provide 'key-combo-web)
