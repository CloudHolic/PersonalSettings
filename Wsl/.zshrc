# Created by newuser for 5.9

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

# Zinit Initialization
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"

# Starship
eval "$(starship init zsh)"

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab

# Zoxide
eval "$(zoxide init zsh)"

# Basic options
setopt AUTO_CD
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Aliases
alias ls='eza --icons'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias lt='eza --tree --level=2 --icons'
alias cat='bat'
alias vi='nvim'
alias vim='nvim'

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gco='git checkout'
alias gb='git branch'
alias gd='git diff'
alias glog='git log --oneline --graph --decorate --all'

# Move directory
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# System
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias remove='sudo pacman -Rs'
alias search='pacman -Ss'

# Env
export EDITOR=nvim
export VISUAL=nvim
export PAGER=less

# fzf
export FZF_DEFALT_OPTS='--height 40% --layout=reverse --border'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Key binding
bindkey -v

# Ctrl+R: Search history
bindkey '^R' fzf-history-widget

bindkey '^[[2~' overwrite-mode          # Insert
bindkey '^[[3~' delete-char             # Delete
bindkey '^[[H' beginning-of-line        # Home
bindkey '^[[1~' beginning-of-line       # Home (Alternative)
bindkey '^[[F' end-of-line              # End
bindkey '^[[4~' end-of-line             # End (Alternative)
bindkey '^[[5~' up-line-or-history      # Page Up
bindkey '^[[6~' down-line-or-history    # Page Down

bindkey '^[[1;5C' forward-word          # Ctrl+->
bindkey '^[[1;5D' backward-word         # Ctrl+<-
bindkey '^[[3;5~' kill-word             # Ctrl+Delete
bindkey '^H' backward-kill-word         # Ctrl+Backsapce

bindkey '^[b' backward-word             # Alt+B
bindkey '^[f' forward-word              # Alt+F
bindkey '^[d' kill-word                 # Alt+D

# sudo
alias sudo='sudo '
alias svim='sudoedit'
alias sedit='sudoedit'

# Dev Env

# .NET
_dotnet_zsh_complete() {
    local completions=("$(dotnet complete "$words")")
    reply=( "${(ps:\n:)completions}" )
}
compctl -K _dotnet_zsh_complete dotnet

# Haskell
[ -f "/home/cloudholic/.ghcup/env" ] && . "/home/cloudholic/.ghcup/env" # ghcup-env

# Python
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
. "$HOME/.local/bin/env"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# bun completions
[ -s "/home/cloudholic/.bun/_bun" ] && source "/home/cloudholic/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

# Ruby
export PATH="$HOME/.local/share/gem/ruby/3.4.0/bin:$PATH"

# Ruby(rvenv)
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - zsh)"
