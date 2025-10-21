(use-modules (gnu)
             (gnu home)
             (gnu home services dotfiles)
             (gnu home services shells)
             (gnu home services xdg)
             (gnu packages shellutils)
             )

(home-environment
 (packages (specifications->packages
            (list "git"
                  "vim"
                  "grep"
                  "ripgrep"
                  "nss-certs"
                  "htop"

                  ;; emacs
                  "emacs-no-x-toolkit"
                  "mu"
                  "tree-sitter"

                  ;; ZSH support
                  ;; prompt
                  "starship"

                  ;; ls replacement
                  "eza"

                  ;; replacement for hyprland
                  "waybar"
                  "niri"
                  "fuzzel"

                  ;; plugins
                  "zsh-autosuggestions"
                  "zsh-history-substring-search"

                  ;; zsh-autopair
                  ;; zsh-completions
                  ;; zsh-syntax-highlighting
                  ;; zsh-vi-mode
                  ;; zfs-tab ?
                  ;; direnv ?

                  ;; "librewolf"
                  ;; "freecad"
                  ;; "librecad"
                  ;; "remmina"
                  ;; "freerdp"
                  "nextcloud-client"

                  ;; packaged but need user in corectrl group - maybe better to leave it to SD?
                  ;; also specific to kocour
                  ;; corectrl

                  )))

 (services (list
            ;; (service corectrl-helper-service-type)
            ;; Zsh service
            (service home-zsh-service-type
                     (home-zsh-configuration
                      (xdg-flavor? #t)

                      (zshrc (list
                              (plain-file "starship"
                                          "eval \"$(starship init zsh)\""
                                          )

                              (mixed-text-file "zsh-autosuggestions"
                                               "source " zsh-autosuggestions "/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh")

                              (mixed-text-file "zsh-history-substring-search"
                                               "source " zsh-history-substring-search "/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh")

                              (local-file "../../config.files/.zshrc" "zshrc-local")

                              ))

                      (environment-variables
                       `(
                         ;; Don't forget to run ~doom env~ after changing PATH if you use Doom Emacs.
                         ("XDG_STATE_HOME" . "$HOME/.local/state")

                         ;; adjusted to include system dirs
                         ("XDG_DATA_DIRS" . "${XDG_DATA_DIRS}/usr/local/share:/usr/share")
                         ("XDG_CONFIG_DIRS" . "${XDG_CONFIG_DIRS}/etc/xdg")
                         ("XCURSOR_PATH" . "${XCURSOR_PATH}/usr/share/icons")
                         ("INFOPATH" . "${INFOPATH}/usr/share/info")
                         ("MANPATH" . "${MANPATH}/usr/share/man")

                         ;; rest
                         ("PATH" . "$HOME/bin:$HOME/.local/bin:$HOME/.guix-home/profile/bin:$HOME/.pyenv/bin:$HOME/.emacs.d/bin:$PATH")
                         ("HISTFILE" . "$XDG_STATE_HOME/.zsh_history")
                         ("HISTSIZE" . "1000000000")
                         ("SAVEHIST" . "1000000000")
                         ("SSL_CERT_DIR" . "$HOME/.guix-home/profile/etc/ssl/certs")
                         ("SSL_CERT_FILE" . "$HOME/.guix-home/profile/etc/ssl/certs/ca-certificates.crt")
                         ("TERM" . "xterm-256color")))
                      ;; (zshenv
                      ;;  (list
                      ;;   (local-file ".zshenv")
                      ;; (zshrc
                      ;;  (list (computed-file "zshrc"
                      ;;                       )
                      ;;   (local-file "zshrc" ".zshrc")))
                      )
                     )
            (service home-dotfiles-service-type
                     (home-dotfiles-configuration
                      (directories '("../../config.files"))))
            )))
