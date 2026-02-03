(define-module (kepi home base-home)
  #:use-module (gnu)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services shells)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu packages shellutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (gnu packages wm)
  #:export (base-packages
            base-services
            %host-files-dir
            make-home-for-host))

;; ---------------------------------------------------------------
;; Pomocné funkce
;; ---------------------------------------------------------------

;; Cesta k host-specifickým souborům spravovaným chezmoi
(define (%host-files-dir)
  (let ((dir (canonicalize-path
              (string-append (getenv "HOME")
                             "/dev/kepi/dotfiles/files/"
                             (gethostname)))))
    (system* "chezmoi" "apply" "--force" "--keep-going"
             "--destination" dir)
    dir))

;; ---------------------------------------------------------------
;; Sdílené balíčky (společné pro všechny stroje)
;; ---------------------------------------------------------------

(define base-packages
  (specifications->packages
   (list
    ;; core tools
    "git"
    "glibc-locales"
    "vim"
    "tmux"
    "grep"
    "ripgrep"
    "nss-certs"
    "htop"

    ;; flatpak
    "flatpak"

    ;; terminal
    "alacritty"

    ;; emacs
    "emacs-no-x-toolkit"
    "emacs-geiser"
    "emacs-geiser-guile"
    "tree-sitter"
    "emacs-pdf-tools"
    "emacs-flymake-ansible-lint"
    "font-jetbrains-mono"
    "font-iosevka-aile"
    "pandoc"
    "shellcheck"
    "nixfmt"

    ;; mail
    "mu"
    "isync"
    "msmtp"

    ;; python
    "python-pylint"

    ;; org-babel support
    "screen"
    "graphviz"

    ;; ruby
    "ruby-solargraph"
    "ruby-rubocop"

    ;; zsh
    "starship"
    "fzf-tab"
    "zoxide"
    "eza"
    "fzf"

    ;; browsers
    "qutebrowser"
    "librewolf"
    "ungoogled-chromium-wayland"

    ;; wayland / niri
    "waybar"
    "niri"
    "wtype"
    "xwayland-satellite"
    "xdg-desktop-portal-wlr"
    "xdg-desktop-portal-gtk"
    "qtwayland"

    ;; desktop
    "kdeconnect"
    "swaynotificationcenter"
    "fuzzel"
    "nomacs"
    "nextcloud-client"

    ;; apps
    "calibre"
    "tuba"
    "xournalpp"
    "evince"
    "libreoffice"
    "gimp"
    "inkscape"
    "plantuml"
    "prusa-slicer"

    ;; zsh plugins
    "zsh-autosuggestions"
    "zsh-history-substring-search"

    ;; gaming
    "lutris-wrapped"

    ;; networking
    "mtr"

    ;; containers
    "podman"
    "podman-compose"

    ;; monitoring
    "btop")))

;; ---------------------------------------------------------------
;; Sdílené services
;; ---------------------------------------------------------------

(define (base-services host-files-dir)
  (list
   ;; --- Zsh ---
   (service home-zsh-service-type
            (home-zsh-configuration
             (xdg-flavor? #t)
             (zshrc (list
                     (plain-file "starship"
                                 "eval \"$(starship init zsh)\"")
                     (mixed-text-file "zsh-autosuggestions"
                                      "source " zsh-autosuggestions
                                      "/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh")
                     (mixed-text-file "zsh-history-substring-search"
                                      "source " zsh-history-substring-search
                                      "/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh")
                     (local-file (string-append host-files-dir "/.zshrc")
                                 "zshrc-local")
                     (mixed-text-file "fzf-tab"
                                      "source " fzf-tab
                                      "/share/zsh/plugins/fzf-tab/fzf-tab.zsh")
                     (plain-file "mise"
                                 "eval \"$(mise activate zsh)\"")
                     (plain-file "zoxide"
                                 "eval \"$(zoxide init --cmd j zsh)\"")))
             (environment-variables
              `(("XDG_STATE_HOME" . "$HOME/.local/state")

                ;; Systémové cesty (pro Arch host)
                ("XDG_DATA_DIRS" . "${XDG_DATA_DIRS}:/usr/local/share:/usr/share")
                ("XDG_CONFIG_DIRS" . "${XDG_CONFIG_DIRS}:/etc/xdg")
                ("XCURSOR_PATH" . "${XCURSOR_PATH}:/usr/share/icons")
                ("INFOPATH" . "${INFOPATH}:/usr/share/info")
                ("MANPATH" . "${MANPATH}:/usr/share/man")

                ("PATH" . "$HOME/bin:$HOME/.local/bin:$HOME/.guix-home/profile/bin:$HOME/.pyenv/bin:$HOME/.emacs.d/bin:$PATH")
                ("HISTFILE" . "$XDG_STATE_HOME/.zsh_history")
                ("HISTSIZE" . "1000000000")
                ("SAVEHIST" . "1000000000")
                ("SSL_CERT_DIR" . "$HOME/.guix-home/profile/etc/ssl/certs")
                ("SSL_CERT_FILE" . "$HOME/.guix-home/profile/etc/ssl/certs/ca-certificates.crt")
                ("TERM" . "xterm-256color")))))

   ;; --- Docker -> Podman wrappery ---
   (service home-files-service-type
            `((".local/bin/docker"
               ,(computed-file "docker"
                               #~(begin
                                   (with-output-to-file #$output
                                     (lambda ()
                                       (display "#!/bin/sh\nexec podman \"$@\"")))
                                   (chmod #$output #o755))))
              (".local/bin/docker-compose"
               ,(computed-file "docker-compose"
                               #~(begin
                                   (with-output-to-file #$output
                                     (lambda ()
                                       (display "#!/bin/sh\nexec podman-compose \"$@\"")))
                                   (chmod #$output #o755))))))

   ;; --- Dotfiles ---
   (service home-dotfiles-service-type
            (home-dotfiles-configuration
             (directories (list host-files-dir))))

   ;; --- XDG Desktop Portals ---
   (simple-service 'xdg-desktop-portals home-shepherd-service-type
                   (list
                    (shepherd-service
                     (provision '(xdg-desktop-portal-wlr))
                     (documentation "Portal backend for wlroots compositors")
                     (start #~(make-forkexec-constructor
                               (list #$(file-append xdg-desktop-portal-wlr
                                                    "/libexec/xdg-desktop-portal-wlr"))
                               #:environment-variables
                               (cons* (string-append "WAYLAND_DISPLAY="
                                                     (or (getenv "WAYLAND_DISPLAY") "wayland-1"))
                                      (string-append "XDG_RUNTIME_DIR="
                                                     (or (getenv "XDG_RUNTIME_DIR")
                                                         (format #f "/run/user/~a" (getuid))))
                                      (default-environment-variables))))
                     (stop #~(make-kill-destructor)))

                    (shepherd-service
                     (provision '(xdg-desktop-portal-gtk))
                     (documentation "Portal backend for GTK file choosers etc")
                     (start #~(make-forkexec-constructor
                               (list #$(file-append xdg-desktop-portal-gtk
                                                    "/libexec/xdg-desktop-portal-gtk"))
                               #:environment-variables
                               (cons* (string-append "WAYLAND_DISPLAY="
                                                     (or (getenv "WAYLAND_DISPLAY") "wayland-1"))
                                      (string-append "XDG_RUNTIME_DIR="
                                                     (or (getenv "XDG_RUNTIME_DIR")
                                                         (format #f "/run/user/~a" (getuid))))
                                      "GDK_BACKEND=wayland"
                                      (default-environment-variables))))
                     (stop #~(make-kill-destructor)))

                    (shepherd-service
                     (provision '(xdg-desktop-portal))
                     (requirement '(xdg-desktop-portal-wlr xdg-desktop-portal-gtk))
                     (documentation "XDG Desktop Portal")
                     (start #~(make-forkexec-constructor
                               (list #$(file-append xdg-desktop-portal
                                                    "/libexec/xdg-desktop-portal"))
                               #:environment-variables
                               (cons* (string-append "WAYLAND_DISPLAY="
                                                     (or (getenv "WAYLAND_DISPLAY") "wayland-1"))
                                      (string-append "XDG_RUNTIME_DIR="
                                                     (or (getenv "XDG_RUNTIME_DIR")
                                                         (format #f "/run/user/~a" (getuid))))
                                      (default-environment-variables))))
                     (stop #~(make-kill-destructor)))))))

;; ---------------------------------------------------------------
;; Sestavení home-environment pro konkrétní stroj
;; ---------------------------------------------------------------

(define* (make-home-for-host #:key
                             (extra-packages '())
                             (extra-services '()))
  (let ((host-files-dir (%host-files-dir)))
    (home-environment
     (packages (append base-packages extra-packages))
     (services (append (base-services host-files-dir)
                       extra-services)))))
