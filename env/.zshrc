# Set up the prompt

plugins+=(bazel)

if [ -d /usr/share/zsh/site-functions ]; then
  fpath=(/usr/share/zsh/site-functions $fpath)
fi

alias vi=nvim
alias v="vi ."
alias ls=eza

export DOTPATH="$HOME/x/dot-repo"
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8
export PATH="$DOTPATH/scripts:$PATH"

# uv
export UV_NO_MANAGED_PYTHON=1
export UV_PYTHON=$(which python)

files_to_source=(
  "$DOTPATH/scripts/nix-fns.sh"
  "$DOTPATH/scripts/fns.sh"
)

for file in "${files_to_source[@]}"; do
  if [ -f "$file" ]; then
    . "$file"
  fi
done

autoload -Uz promptinit
promptinit

PROMPT='%(?.%F{green}√.%F{red}?%?)%f %B%F{240}%1~%f%b %# '

setopt histignorealldups sharehistory

# Use vim keybindings
bindkey -v
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^R" history-incremental-search-backward
bindkey "^P" history-incremental-search-forward

# Home and End keys
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line

HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit

if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

source <(jj util completion zsh)

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh

bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search

zmodload zsh/complist

bindkey '^n' menu-complete
bindkey '^u' accept-and-menu-complete

bindkey -M menuselect '^n' accept-and-infer-next-history
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

function fg-widget() {
  fg
  zle reset-prompt  # Optional: redraw prompt after resuming
}

zle -N fg-widget
bindkey '^f' fg-widget  # Binds Ctrl-f to fg

eval "$(zoxide init zsh)"
