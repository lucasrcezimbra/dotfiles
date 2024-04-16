# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

# pipx
export PATH="$HOME/.local/bin:$PATH"

# Oh my zsh
export ZSH=~/.oh-my-zsh
export EDITOR='vim'

ZSH_THEME="af-magic"
plugins=(
  # commands
  copyfile
  copypath
  gitignore
  qrcode
  universalarchive
  urltools
  web-search

  # tools
  bgnotify
  command-not-found
  extract
  globalias
  per-directory-history
  safe-paste

  # shortcuts
  copybuffer

  # UI
  colored-man-pages
  virtualenv

  # aliases and completion
  pip
  terraform
  yarn

  # completion only
  fd
  gh
  gitfast
  poetry
  ripgrep
  ufw

  # init
  mise
  pyenv
  starship
  zoxide
)

source $ZSH/oh-my-zsh.sh

# _experiments
alias ls='eza --icons'
alias grep=rg
alias find=fd
alias wezterm='flatpak run org.wezfurlong.wezterm'
alias gcllm='cat <(echo "Last commits:") <(git lg -n 10) <(echo "\n\ngit diff:") <(git diff --cached) | llm -t commit'

# aws
alias av='aws-vault'
alias ave='aws-vault exec'
alias avl='aws-vault login'

# configs
alias lvimconfig="cd ~/.dotfiles && vim lvim.lua"
alias nvimconfig="cd ~/.dotfiles && vim nvimrc"
alias vimconfig="cd ~/.dotfiles && vim vimrc"
alias zshconfig="vim ~/.dotfiles/zshrc"
alias zshlconfig="vim ~/.dotfiles/zshrc.local"
alias wezconfig="vim ~/.dotfiles/wezterm.lua"

# Docker
alias ,dockerkillall="docker ps -q | xargs docker kill"

# files
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'

# git
alias g='git'
alias ga='git add'
alias gb='git branch'
alias gc='git commit'
alias gd='git diff'
alias gd-='git diff --cached'
alias gf='git fetch -a'
alias gk='git checkout'
alias gll='git pull'
alias gpp='git pull && git push'
alias gs='git status'
alias gsh='git push'
alias gsh-='git push --set-upstream origin $(git rev-parse --abbrev-ref HEAD)'
alias gig='gi'

# helpers
alias calc="python -c \"import sys; print(eval(''.join(sys.argv[1:])))\""
alias c=calc
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'
eval $(thefuck --alias)

# navigation
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias cd=z
alias j=z

# neovim
alias vim=lvim
alias v=lvim
export PATH="$HOME/.local/bin:$PATH"

# python
alias sa='source .venv/bin/activate'
alias manage='python $VIRTUAL_ENV/../manage.py'
alias pmanage='poetry run python manage.py'

# selenium
export CHROME_BIN=chromium

# snap
export PATH="/snap/bin:$PATH"

# globalias
GLOBALIAS_FILTER_VALUES=(calc pip timer wezterm \*)

function n(){
  if [ $1 ]; then
    thunar $1 2> /dev/null
  else
    thunar $PWD 2> /dev/null
  fi
}

function vpn() {
  nmcli connection delete pvpn-ipv6leak-protection
  protonvpn-cli c --cc BR
}

. ~/.dotfiles/zshrc.local
