(add-to-load-path
 (string-append (dirname (current-filename)) "/../modules"))

;; Get system name from GUIX_SYSTEM env var, or fall back to hostname
(define system-name (or (getenv "GUIX_SYSTEM") (gethostname)))

;; Dynamically load the module and get the *-home variable
(let ((mod (resolve-module `(kepi systems ,(string->symbol system-name)))))
  (module-ref mod (string->symbol (string-append system-name "-home"))))
