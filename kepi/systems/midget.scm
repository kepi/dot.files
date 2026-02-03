(define-module (kepi systems midget)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu packages)
  #:use-module (kepi home base-home)
  #:use-module (kepi home services flatpak))

(define midget-packages
  (specifications->packages
   (list)))

(define midget-flatpak
  (flatpak-service
   (make-flatpak-configuration
    #:packages '("org.kde.okular"
                 "io.github.alescdb.mailviewer")
    #:global-overrides '("--filesystem=~/tmpfs")
    #:app-overrides '(("org.kde.okular" "--filesystem=~/.pki:ro")))))

(make-home-for-host
 #:extra-packages midget-packages
 #:extra-services (list midget-flatpak
                        (flatpak-environment-service)))
