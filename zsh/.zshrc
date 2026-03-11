### ─────────────────────────────────────────────
###  Oh-My-Zsh
### ─────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
export PATH="/home/mohiitp/.local/share/solana/install/active_release/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

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

#tmux open throught fuzzy finding
# Fuzzy-pick a directory and open it in a tmux session
tmux-fzf() {
  local dir session

  # Pick a directory (customize search roots if you want)
  dir=$(find ~/ -type d -maxdepth 3 2>/dev/null | fzf) || return

  # Session name = directory name (sanitized)
  session=$(basename "$dir" | tr . _)

  # If tmux not running, start it
  if ! tmux info &>/dev/null; then
    tmux new-session -s "$session" -c "$dir"
    return
  fi

  # Create session if it doesn't exist
  if ! tmux has-session -t "$session" 2>/dev/null; then
    tmux new-session -ds "$session" -c "$dir"
  fi

  # Switch to it
  tmux switch-client -t "$session"
}

zle -N tmux-fzf
bindkey '^F' tmux-fzf

### ─────────────────────────────────────────────
### Aliases
### ─────────────────────────────────────────────

alias python="/usr/bin/python3"

# navigation + tools
alias vi="nvim"
alias v="vim"
# alias ls="eza --icons"
# alias ll="eza --long"
# alias la="eza --long --all"
# alias lt="eza --tree"
alias yy="yazi"
alias ta="tmux a"
alias tnew="tmux new-session -s"
alias td="tmux kill-session -t"
alias delete_default="tmux kill-session -t default"
alias editzsh="nvim ~/.zshrc"
alias sourcezsh="source ~/.zshrc"
alias ins="yay -S" 
alias sea="yay -Ss" 
alias open="xdg-open"

# Git shortcuts
alias ga="git pull origin main && git add ."
alias gc="git commit -m"
alias gp="git push origin main"
alias gpl="git pull origin main"
alias gs="git status"

# Project shortcuts
alias mg="cd ~/moLib/moGit"
alias mc="cd ~/moLib/moCode"
alias mn="cd ~/moLib/moNote"
alias todo="vi  ~/moLib/todo.md"
alias ml="vi  ~/moLib/moNote/100x_ai/ml_notes1.md"
alias nrd="npm run dev"
alias nrs="npm run start"
alias nrb="npm run build"
alias jc="javac"
alias j="java"

### ─────────────────────────────────────────────
### Tmux auto-attach
### ─────────────────────────────────────────────
[ -z "$TMUX" ] && (tmux attach-session -t todo || tmux new-session -s default)

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


# pnpm
export PNPM_HOME="/Users/mohit_iitp/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

echo "Kaise ho Mohiitp bhai"
uwufetch

# bun completions
[ -s "/Users/mohit_iitp/.bun/_bun" ] && source "/Users/mohit_iitp/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.config/emacs/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
