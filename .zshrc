# Set up the prompt

if [ -n "$DISPLAY" ]; then
  setxkbmap -option "caps:escape"
fi

alias v="vi ."
alias ls=eza

files_to_source=(
  "$HOME/dot-repo/fns.sh"
  "$HOME/.cargo/env"
)

for file in "${files_to_source[@]}"; do
  if [ -f "$file" ]; then
    . "$file"
  fi
done

if command -v jj &>/dev/null; then
  source <(jj util completion --zsh)
fi

autoload -Uz promptinit
promptinit

PROMPT='%(?.%F{green}√.%F{red}?%?)%f %B%F{240}%1~%f%b %# '

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -v
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^R" history-incremental-search-backward

HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search
