ulimit -s 65536
ulimit -c unlimited

export VISUAL=nvim
export EDITOR="$VISUAL"

export FZF_DEFAULT_COMMAND="rg --files"

if [ -e "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]; then
  . "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
fi
