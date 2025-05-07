#!/usr/bin/env bash

cap() { read foo; printf -v tmp "$foo" }
ret() { echo $tmp }
rgh() { rg -e "^" -e $1 }

# Copy to clipboard
clip() { xclip -sel c }

# Copy to clipboard for a language model
cliplm() {
  for file in "$@"; do
    echo "File: $file\n\`\`\`\n$(cat "$file")\n\`\`\`\n" 
  done | xclip -sel c
}

# ps -ef with interactive search
psef() {
  FZF_DEFAULT_COMMAND='ps -ef' \
    fzf --bind "ctrl-r:reload(ps -ef)" \
      --header 'Press CTRL-R to reload' --header-lines=1 \
      --height=50% --layout=reverse
}

# Aliases
scripts=$(realpath $(dirname $0))

# Watch and exec respecting .gitignore.
wx()  { $scripts/wx.sh $@ }

t1() { tree -L 1 . }
t2() { tree -L 2 . }
t3() { tree -L 3 . }
t4() { tree -L 4 . }

# generate random password to clipboard
gpw() { < /dev/urandom tr -dc '[:graph:]' | head -c 16 | clip }
