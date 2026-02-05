(define-module (kepi systems midget)
  #:use-module (gnu packages)
  #:use-module (kepi home base-home)
  #:use-module (kepi home services flatpak)
  #:export (midget-home))

(define midget-packages
  (specifications->packages
   (list
    "wvkbd"
    "wdisplays")))

(define midget-flatpak
  (flatpak-service
   (make-flatpak-configuration
    #:packages '("org.kde.okular"
                 "io.github.alescdb.mailviewer")
    #:global-overrides '("--filesystem=~/tmpfs")
    #:app-overrides '(("org.kde.okular" "--filesystem=~/.pki:ro")))))

(define midget-home
  (make-home-for-host
   #:extra-packages midget-packages
   #:extra-services (list midget-flatpak
                          (flatpak-environment-service))))
