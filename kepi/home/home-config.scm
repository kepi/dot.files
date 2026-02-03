(define-module (kepi home home-config)
  #:use-module (gnu)
  #:use-module (guix inferior)
  #:use-module (guix channels)
  #:use-module (srfi srfi-1)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu home services shells)
  #:use-module (gnu home services xdg)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu packages shellutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (emacs packages melpa)
  #:use-module (guix utils)
  #:use-module (gnu packages wm)
  #:use-module (guix packages)
  #:use-module (kepi packages kitty)
  #:use-module (kepi home services flatpak))


;; Get the directory containing this config file
;; (define current-dir (dirname (current-filename)))
;; (define current-dir (dirname (current-source-directory)))
(define current-dir (string-append (getenv "HOME") "/dev/kepi/dotfiles/kepi/home"))

;; Build absolute path from config directory
(define host-files-dir
  (canonicalize-path
    (string-append current-dir "/../../files/" (gethostname))))

(system* "chezmoi" "apply" "--force" "--keep-going" "--destination" host-files-dir)

(home-environment
 (packages (append (list)



                        ;;niri-fixed
                        ;; qutebrowser-from-pr)


                 (specifications->packages
                  (list "git"
                        "glibc-locales"
                        "vim"
                        "tmux"
                        "grep"
                        "ripgrep"
                        "nss-certs"
                        "htop"

                        "flatpak"

                        ;; terminal apps. Kitty only for ~ console like overlay use
                        ;; until it is supported with special workspaces in niri
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

                        ;; mu - aka maildir utils
                        "mu"
                        "isync"
                        "msmtp"

                        ;; python
                        "python-pylint"

                        ;; loosely related to emacs and org
                        ;; for org-babel
                        "screen"
                        "graphviz"

                        ;; i have this in arch still as i need gscan2pdf which depends on it
                        ;; "imagemagick"

                        ;; for ruby
                        "ruby-solargraph"
                        "ruby-rubocop"

                        ;; ZSH support
                        ;; prompt
                        "starship"
                        "fzf-tab"
                        "zoxide" ;; z replacement
                        "eza" ;; ls replacement
                        "fzf" ;; fast fuzzy searching - various uses (for Ctrl+R i.e.)

                        ;; nushell ... I'm going crazy
                        ;; "nushell"
                        ;; TODO set .local/share/nushell/vendor/autoload/starship.nu from running starship init nu
                        ;; TODO: rozhodnout jestli do toho pujdu, zatim lze přes guix shell

                        "qutebrowser"
                        ;; "vulkan-loader"
                        ;; "mesa-headers"

                        ;; replacement for hyprland
                        "waybar"
                        "niri" ;; https://github.com/YaLTeR/niri/wiki/IPC kdyby bylo třeba časem
                        "wtype"
                        "xwayland-satellite"
                        ;; "xdg-desktop-portal"
                        "xdg-desktop-portal-wlr"
                        "xdg-desktop-portal-gtk"

                        ;; IMPORTANT: enabling this breaks QT apps which aren't installed from Guix
                        ;; if you want to run almost any QT app which isn't installed from guix, you have to run it with
                        ;; QT_PLUGIN_PATH=/usr/lib/qt6/plugins otherwise it will crash.
                        "qtwayland"
                        "kdeconnect"

                        "swaynotificationcenter"
                        "fuzzel"
                        "nomacs"

                        ;; features
                        "calibre"

                        ;; mastodon
                        "tuba"

                        ;; pdf, notetaking etc
                        "xournalpp"
                        "evince"

                        ;; tools I'm using through guix shell so I don't have to install them
                        ;; "lshw"
                        ;; "hwinfo"
                        ;; "asciinema"

                        ;; plugins
                        "zsh-autosuggestions"
                        "zsh-history-substring-search"

                        ;; zsh-autopair
                        ;; zsh-completions
                        ;; zsh-syntax-highlighting
                        ;; zsh-vi-mode
                        ;; zfs-tab ?
                        ;; direnv ?

                        "librewolf"
                        ;; "freecad"
                        ;; "librecad"
                        ;; "remmina"
                        ;; "freerdp"
                        ;;
                        ;; DESKTOP
                        "nextcloud-client"

                        "ungoogled-chromium-wayland"

                        "lutris-wrapped"

                        "darktable"
                        ;; FIXME: we need different package for surface, rocm is only for AMD systems
                        ;; "rocm-opencl-runtime" ;; darktable needs opencl

                        ;; gaming
                        ;; "steam"

                        ;; various tools
                        "libreoffice"
                        "gimp"
                        "inkscape"
                        "plantuml"
                        "prusa-slicer"
                        ;; when I need it, it is packaged
                        ;; "signal-desktop"
                        ;; "okular"
                        ;;

                        ;; screen recording
                        ;; "peek"

                        ;; audio/video processing
                        "obs"
                        ;; "wf-recorder"

                        ;; networking tools I use often
                        "mtr"

                        ;; podman - at least until I move fully to guix containers but
                        ;; probably for testing later too
                        "podman"
                        "podman-compose"

                        ;; btop for displaying system usage
                        "btop"))))

                  ;; packaged but need user in corectrl group - maybe better to leave it to SD?
                  ;; also specific to kocour
                  ;; "corectrl"


 (services (list
            ;; (service corectrl-helper-service-type)
            ;; Zsh service

            (service home-zsh-service-type
                     (home-zsh-configuration
                      (xdg-flavor? #t)

                      (zshrc (list
                              (plain-file "starship"
                                          "eval \"$(starship init zsh)\"")

                              (mixed-text-file "zsh-autosuggestions"
                                               "source " zsh-autosuggestions "/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh")

                              (mixed-text-file "zsh-history-substring-search"
                                               "source " zsh-history-substring-search "/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh")

                              (local-file (string-append host-files-dir "/.zshrc") "zshrc-local")

                              (mixed-text-file "fzf-tab"
                                               "source " fzf-tab "/share/zsh/plugins/fzf-tab/fzf-tab.zsh")

                              ;; #FIXME: add mise to guix directly and correct path after
                              ;; mise settings add idiomatic_version_file_enable_tools ruby
                              ;; mise settings add idiomatic_version_file_enable_tools python
                              (plain-file "mise"
                                          "eval \"$(mise activate zsh)\"")

                              (plain-file "zoxide"
                                          "eval \"$(zoxide init --cmd j zsh)\"")))

                      (environment-variables
                       `(
                         ("XDG_STATE_HOME" . "$HOME/.local/state")

                         ;; adjusted to include system dirs
                         ("XDG_DATA_DIRS" . "${XDG_DATA_DIRS}/usr/local/share:/usr/share")
                         ;; ("XDG_DATA_DIRS" . "$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:${XDG_DATA_DIRS}:/usr/local/share:/usr/share")
                         ("XDG_CONFIG_DIRS" . "${XDG_CONFIG_DIRS}/etc/xdg")
                         ("XCURSOR_PATH" . "${XCURSOR_PATH}/usr/share/icons")
                         ("INFOPATH" . "${INFOPATH}/usr/share/info")
                         ("MANPATH" . "${MANPATH}/usr/share/man")

                         ;; Don't forget to run ~doom env~ after changing PATH if you use Doom Emacs.
                         ("PATH" . "$HOME/bin:$HOME/.local/bin:$HOME/.guix-home/profile/bin:$HOME/.pyenv/bin:$HOME/.emacs.d/bin:$PATH")
                         ("HISTFILE" . "$XDG_STATE_HOME/.zsh_history")
                         ("HISTSIZE" . "1000000000")
                         ("SAVEHIST" . "1000000000")
                         ("SSL_CERT_DIR" . "$HOME/.guix-home/profile/etc/ssl/certs")
                         ("SSL_CERT_FILE" . "$HOME/.guix-home/profile/etc/ssl/certs/ca-certificates.crt")
                         ("TERM" . "xterm-256color")))))

            (service home-files-service-type
                `(
                  (".local/bin/docker"
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

            (service home-dotfiles-service-type
                (home-dotfiles-configuration
                    (directories (list host-files-dir))))

            (simple-service 'xdg-desktop-portals home-shepherd-service-type
              (list
                (shepherd-service
                  (provision '(xdg-desktop-portal-wlr))
                  (documentation "Portal backend for wlroots compositors")
                  (start #~(make-forkexec-constructor
                            (list #$(file-append xdg-desktop-portal-wlr
                                     "/libexec/xdg-desktop-portal-wlr"))
                            #:environment-variables
                            (cons* (string-append "WAYLAND_DISPLAY=" (or (getenv "WAYLAND_DISPLAY") "wayland-1"))
                                   (string-append "XDG_RUNTIME_DIR=" (or (getenv "XDG_RUNTIME_DIR") (format #f "/run/user/~a" (getuid))))
                                   (default-environment-variables))))
                  (stop #~(make-kill-destructor)))

                (shepherd-service
                  (provision '(xdg-desktop-portal-gtk))
                  (documentation "Portal backend for GTK file choosers etc")
                  (start #~(make-forkexec-constructor
                            (list #$(file-append xdg-desktop-portal-gtk
                                     "/libexec/xdg-desktop-portal-gtk"))
                            #:environment-variables
                            (cons* (string-append "WAYLAND_DISPLAY=" (or (getenv "WAYLAND_DISPLAY") "wayland-1"))
                                   (string-append "XDG_RUNTIME_DIR=" (or (getenv "XDG_RUNTIME_DIR") (format #f "/run/user/~a" (getuid))))
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
                            (cons* (string-append "WAYLAND_DISPLAY=" (or (getenv "WAYLAND_DISPLAY") "wayland-1"))
                                   (string-append "XDG_RUNTIME_DIR=" (or (getenv "XDG_RUNTIME_DIR") (format #f "/run/user/~a" (getuid))))
                                   (default-environment-variables))))
                  (stop #~(make-kill-destructor)))))
            (flatpak-service
             (make-flatpak-configuration
              #:remotes '(("flathub" "https://flathub.org/repo/flathub.flatpakrepo"))
              #:packages '("org.kde.okular"
                           "io.github.alescdb.mailviewer")
              #:global-overrides '("--filesystem=~/tmpfs")
              #:app-overrides '(("org.kde.okular" "--filesystem=~/.pki:ro"))))
            (flatpak-environment-service))))

;; (define niri-fixed
;;  (package
;;    (inherit niri)
;;    (arguments
;;     (ensure-keyword-arguments (package-arguments niri)
;;                               '(#:cargo-install-paths '("."))))))

;; ;; qutebrowser fix start
;; ;; https://codeberg.org/guix/guix/pulls/3342
;; (define channels-with-qtwebengine-fix
;;   (list (channel
;;          (name 'guix)
;;          (url "https://codeberg.org/guix/guix.git")
;;          (branch "refs/pull/3342/head")
;;          (introduction
;;                      (make-channel-introduction
;;                         "9edb3f66fd807b096b48283debdcddccfea34bad"
;;                         (openpgp-fingerprint
;;                             "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))))

;; (define inferior
;;   (inferior-for-channels channels-with-qtwebengine-fix))

;; (define qutebrowser-from-pr
;;   (first (lookup-inferior-packages inferior "qutebrowser")))
;; ;; qutebrowser fix end
