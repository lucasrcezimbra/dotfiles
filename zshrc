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
  gh
  gitfast
  poetry
  tailscale
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
alias find=fd
alias gcllm='cat <(echo "Last commits:") <(git lg -n 10) <(echo "\n\ngit diff:") <(git diff --cached) | llm -t commit'

# aws
alias av='aws-vault'
alias ave='aws-vault exec'
alias avl='aws-vault login'

# configs
alias ,.="cd ~/.dotfiles && lvim +NvimTreeOpen"
alias ,.lvim="lvim ~/.dotfiles/lvim.lua"
alias ,.nvim="lvim  ~/.dotfiles/nvimrc"
alias ,.vim="lvim ~/.dotfiles/vimrc"
alias ,.zsh="lvim ~/.dotfiles/zshrc"
alias ,.zshlocal="lvim ~/.dotfiles/zshrc.local"
alias ,.wez="lvim ~/.dotfiles/wezterm.lua"

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
alias gcp='git cherry-pick'
alias gcwip='git commit --no-verify -m WIP'
alias gd='git diff'
alias gd-='git diff --cached'
alias gf='git fetch -a'
alias gk='git checkout'
alias glg='git lg'
alias gll='git pull --autostash origin $(git rev-parse --abbrev-ref HEAD)'
alias gpp='git pull && git push'
alias gr='git reset'
alias gs='git status'
alias gsh='git push origin $(git rev-parse --abbrev-ref HEAD)'
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

# notes
NOTES_ROOT_PATH="$HOME/workspace/lucasrcezimbra.github.io/"
NOTES_PATH="$NOTES_ROOT_PATH/content/anotacoes/"
alias ,first-weekday='date -d "last saturday day" "+%Y-%m-%d"'
alias ,last-weekday='date -d "this friday day" "+%Y-%m-%d"'
alias ,week='echo $(,first-weekday) - $(,last-weekday)'
alias notes='cd $NOTES_PATH && lvim +NvimTreeOpen +Telescope\ fd'
alias wnote='cd $NOTES_PATH && lvim "Weeknotes/$(,week).md"'
alias rnotes='_,run-notes && notes'
alias rwnote='_,run-notes && wnote'
alias _,run-notes='wezterm cli split-pane --right --percent 20 --cwd $NOTES_ROOT_PATH -- zsh -i -c "hugo server --bind 0.0.0.0"'

# python
alias sa='source .venv/bin/activate'
alias manage='python $VIRTUAL_ENV/../manage.py'
alias pmanage='poetry run python manage.py'
## django
alias ,djcreatesuperuser="DJANGO_SUPERUSER_PASSWORD=12345678 poetry run python manage.py createsuperuser --username lucas --email lucas@cezimbra.tec.br --noinput"

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
