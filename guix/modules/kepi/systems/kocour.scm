(define-module (kepi systems kocour)
  #:use-module (gnu packages)
  #:use-module (kepi home base-home)
  #:use-module (kepi home services flatpak)
  #:export (kocour-home))

(define kocour-packages
  (specifications->packages
   (list
    "obs"
    "darktable"
    "rocm-opencl-runtime")))

(define kocour-flatpak
  (flatpak-service
   (make-flatpak-configuration
    #:packages '("org.kde.okular"
                 "io.github.alescdb.mailviewer")
    #:global-overrides '("--filesystem=~/tmpfs")
    #:app-overrides '(("org.kde.okular" "--filesystem=~/.pki:ro")))))

(define kocour-home
  (make-home-for-host
   #:extra-packages kocour-packages
   #:extra-services (list kocour-flatpak
                          (flatpak-environment-service))))
