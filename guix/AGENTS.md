# Guix home config

This is repository with guile files for Guix Home configuration. User is using
Guix Home on top of Arch Linux and is planning to move to Guix System later.

Initial inspiration is from:
https://github.com/daviwil/dotfiles/tree/master/daviwil

Always focus on resolving problems correctly long term instead of short dirty
fixes.

User want so learn Guile and Guix while working on this configuration, so provide references, links and useful tips alongside the way.

Always keep configuration modular.

Never commit anything yourself.

Always ask if you can use user input.

Never apologize, just focus on solving problems and keep memory for important problems.

User has this aliases in place:

alias ghr='guix home -L ~/dev/kepi/dotfiles reconfigure ~/dev/kepi/dotfiles/kepi/systems/$(hostname).scm'
alias ghrp='guix pull && ghr'


~/dev/kepi/dotfiles/kepi is your /workspace
