### ─────────────────────────────────────────────
###  Oh-My-Zsh
### ─────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions web-search)

source $ZSH/oh-my-zsh.sh

# Autosuggestion color
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#525252'

### ─────────────────────────────────────────────
###  Shell Enhancements
### ─────────────────────────────────────────────
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"  # replaces cd

# Open buffer line in EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

### ─────────────────────────────────────────────
### History config
### ─────────────────────────────────────────────
HISTFILE=$HOME/.zhistory
SAVEHIST=2000
HISTSIZE=2000

setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

### ─────────────────────────────────────────────
### FZF + FD + BAT + RIPGREP Integration
### ─────────────────────────────────────────────

# Load fzf if installed
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Global defaults
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"

export FZF_DEFAULT_OPTS="
  --height 40%
  --layout=reverse
  --border
  --preview-window='right:60%'
  --ansi
"

# Function: open files with preview + nvim
ff() {
  local file
  file=$(fzf --preview 'bat --style=numbers --color=always --line-range=:400 {}')
  [ -n "$file" ] && nvim "$file"
}

# Function: fuzzy cd (directory jump)
fcd() {
  local dir
  dir=$(fd -t d . | fzf)
  [ -n "$dir" ] && cd "$dir"
}

# Function: simple file picker
f() {
  fd . | fzf
}

# Function: search inside files using ripgrep
fsearch() {
  rg --files | fzf --preview 'bat --style=numbers --color=always --line-range=:400 {}'
}

### ─────────────────────────────────────────────
### Aliases
### ─────────────────────────────────────────────

alias python="/usr/bin/python3"

# navigation + tools
alias vi="nvim"
alias v="vim"
alias cd="z"              # zoxide
alias ls="eza --icons"
alias ll="eza --long"
alias la="eza --long --all"
alias lt="eza --tree"
alias yy="yazi"
alias ta="tmux a"
alias editzsh="nvim ~/.zshrc"
alias sourcezsh="source ~/.zshrc"

# Git shortcuts
alias ga="git pull origin main && git add ."
alias gc="git commit -m"
alias gp="git push origin main"
alias gpl="git pull origin main"
alias gs="git status"

# Project shortcuts
alias mg="cd ~/moLib/moGit"
alias nrd="npm run dev"
alias nrs="npm run start"
alias nrb="npm run build"
alias jc="javac"
alias j="java"

### ─────────────────────────────────────────────
### Tmux auto-attach
### ─────────────────────────────────────────────
[ -z "$TMUX" ] && (tmux attach-session -t default || tmux new-session -s default)

### ─────────────────────────────────────────────
### NVM
### ─────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

export EDITOR="nvim"

### ─────────────────────────────────────────────
### Yazi folder exit support
### ─────────────────────────────────────────────
y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

