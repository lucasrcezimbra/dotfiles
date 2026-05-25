source ~/.dotfiles/shellrc

copy-current-line() {
  if ! command -v wl-copy &> /dev/null; then
    printf 'wl-copy not found\n' >&2
    return 1
  fi

  printf %s "$READLINE_LINE" | wl-copy
}

bind -x '"\C-o": copy-current-line'

# atuin (must come after fzf to override Ctrl+R)
if [[ -r /usr/share/bash-preexec/bash-preexec.sh ]]; then
  source /usr/share/bash-preexec/bash-preexec.sh
fi

if command -v atuin &> /dev/null; then
  eval "$(atuin init bash --disable-up-arrow)"
fi
