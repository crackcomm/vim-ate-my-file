ulimit -s 65536
ulimit -c unlimited

if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

export VISUAL=nvim
export EDITOR="$VISUAL"

export FZF_DEFAULT_COMMAND="rg --files"

export ESY__FETCH_CONCURRENCY=$((2 * $(nproc)))
export ESY__BUILD_CONCURRENCY=$(nproc)

export GOROOT=$HOME/.local/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

export NPM_PACKAGES="${HOME}/.npm-packages"
export PATH="$PATH:$NPM_PACKAGES/bin:$HOME/.local/bin"
export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"
