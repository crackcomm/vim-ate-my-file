#!/bin/bash

cap() { read foo; printf -v tmp "$foo" }
ret() { echo $tmp }
hg() { rg -e "^" -e $1 }

# Copy to clipboard
clip() { xclip -sel c }

psef() {
  FZF_DEFAULT_COMMAND='ps -ef' \
    fzf --bind "ctrl-r:reload(ps -ef)" \
      --header 'Press CTRL-R to reload' --header-lines=1 \
      --height=50% --layout=reverse
}
