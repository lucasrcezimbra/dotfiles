source ~/.dotfiles/shellrc

# atuin (must come after fzf to override Ctrl+R)
if [[ -r /usr/share/bash-preexec/bash-preexec.sh ]]; then
  source /usr/share/bash-preexec/bash-preexec.sh
fi

if command -v atuin &> /dev/null; then
  eval "$(atuin init bash --disable-up-arrow)"
fi
