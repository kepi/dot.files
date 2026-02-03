(define-module (kepi home services flatpak)
  #:use-module (gnu home services)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:export (flatpak-service
            flatpak-environment-service
            make-flatpak-configuration))

;; config as associative list
(define* (make-flatpak-configuration
          #:key
          (remotes '(("flathub" "https://flathub.org/repo/flathub.flatpakrepo")))
          (packages '())
          (global-overrides '())
          (app-overrides '()))
  `((remotes . ,remotes)
    (packages . ,packages)
    (global-overrides . ,global-overrides)
    (app-overrides . ,app-overrides)))

(define %default-configuration
  (make-flatpak-configuration))

(define* (flatpak-service #:optional (config %default-configuration))
  (let ((remotes (assoc-ref config 'remotes))
        (packages (assoc-ref config 'packages))
        (global-overrides (assoc-ref config 'global-overrides))
        (app-overrides (assoc-ref config 'app-overrides)))
    (simple-service
     'flatpak-setup home-activation-service-type
     #~(begin
         (use-modules (ice-9 format))

         (define (flatpak . args)
           (format #t "flatpak ~{~a ~}~%" args)
           (zero? (apply system* "flatpak" args)))

         ;; 1. Remotes
         (for-each
          (lambda (remote)
            (flatpak "remote-add" "--user" "--if-not-exists"
                     (car remote) (cadr remote)))
          '#$remotes)

         ;; 2. Packages
         (for-each
          (lambda (app)
            (flatpak "install" "--user" "--noninteractive"
                     "--or-update" "flathub" app))
          '#$packages)

         ;; 3. Global overrides
         (for-each
          (lambda (flag)
            (flatpak "override" "--user" flag))
          '#$global-overrides)

         ;; 4. Per-app overrides
         (for-each
          (lambda (app-override)
            (apply flatpak "override" "--user"
                   (car app-override) (cdr app-override)))
          '#$app-overrides)))))

;; XDG_DATA_DIRS so system see applications, icons etc
(define (flatpak-environment-service)
  (simple-service
   'flatpak-xdg-dirs home-environment-variables-service-type
   `(("XDG_DATA_DIRS" .
      "$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:${XDG_DATA_DIRS}"))))
