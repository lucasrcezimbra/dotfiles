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

  # completion only
  gh
  gitfast
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
alias df="duf"
alias ls='eza --icons'
alias find=fd
alias gcllm='cat <(echo "Last commits:") <(git lg -n 10) <(echo "\n\ngit diff:") <(git diff --cached) | llm -t commit'
alias ,ip="curl -s ifconfig.co"
alias ,ipv4=",ip -4"
alias ,ipv6=",ip -6"
function git_main_branch() {
  # extracted from https://github.com/ohmyzsh/ohmyzsh/blob/2525dae6613652ec9cb572bdc2fdf80ef837a967/plugins/git/git.plugin.zsh#L35-L58
  command git rev-parse --git-dir &>/dev/null || return

  local remote ref

  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,stable,master}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return 0
    fi
  done

  # Fallback: try to get the default branch from remote HEAD symbolic refs
  for remote in origin upstream; do
    ref=$(command git rev-parse --abbrev-ref $remote/HEAD 2>/dev/null)
    if [[ $ref == $remote/* ]]; then
      echo ${ref#"$remote/"}; return 0
    fi
  done

  # If no main branch was found, fall back to master but return error
  echo master
  return 1
}

# aws
alias av='aws-vault'
alias ave='aws-vault exec'
alias avl='aws-vault login'

# configs
alias ,.="cd ~/.dotfiles && vim"
alias ,.lvim="vim ~/.dotfiles/lvim.lua"
alias ,.nvim="vim  ~/.dotfiles/nvimrc"
alias ,.vim="vim ~/.dotfiles/vimrc"
alias ,.zsh="vim ~/.dotfiles/zshrc"
alias ,.zshlocal="vim ~/.dotfiles/zshrc.local"
alias ,.wez="vim ~/.dotfiles/wezterm.lua"

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
alias gcn='git commit --no-verify'
alias gcp='git cherry-pick'
alias gcwip='git commit --no-verify -m WIP'
alias gd='git diff'
alias gd-='git diff --cached'
alias gf='git fetch -a'
alias gk='git checkout'
alias gk.='git checkout -- . && git clean -f'
alias glg='git lg'
alias gll='git pull --autostash origin $(git rev-parse --abbrev-ref HEAD)'
alias gllm='git pull --autostash --no-ff origin $(git_main_branch)'
alias gr='git reset HEAD'
alias gr~='git reset HEAD~1'
alias gs='git status'
alias gsh='git push origin $(git rev-parse --abbrev-ref HEAD)'
alias gig='gi'
# github
alias ghk="gh pr checkout"
alias ghw="gh run watch && notify-send 'Workflow is done!!!11!!'"


# helpers
alias calc="python -c \"import sys; print(eval(''.join(sys.argv[1:])))\""
alias c=calc
alias _,time='date "+%H:%M:%S"'
function ,timer() {
  echo "Timer started at $(_,time). Stop with Ctrl-D."
  /usr/bin/time -f '%E' cat
  echo "Timer stopped at $(_,time)."
}

# paths
NOTES_ROOT_PATH="$HOME/workspace/lucasrcezimbra.github.io"
DOTFILES_PATH="$HOME/.dotfiles"
NOTES_PATH="$NOTES_ROOT_PATH/content/anotacoes"

# navigation
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias cd=z
alias j=z
alias ,znotes="cd $NOTES_ROOT_PATH"
alias ,zinotes="cd $NOTES_ROOT_PATH"
alias ,zdotfiles="cd $DOTFILES_PATH"
alias ,z.="cd $DOTFILES_PATH"

# neovim
alias vim=nvim
alias v=nvim
export PATH="$HOME/.local/bin:$PATH"

# notes
alias _,today='date "+%Y-%m-%d"'
alias _,first-weekday='date -d "last saturday day" "+%Y-%m-%d"'
alias _,last-weekday='date -d "this friday day" "+%Y-%m-%d"'
alias _,week='echo $(_,first-weekday) - $(_,last-weekday)'
alias _,first-work-weekday='date -d "last sunday day" "+%Y-%m-%d"'
alias _,last-work-weekday='date -d "next Friday" "+%Y-%m-%d"'
alias _,work-week='echo $(_,first-weekday) - $(_,last-weekday)'
WEEKNOTE_PATH="$NOTES_PATH/Weeknotes/$(_,week).md"
alias ,notes='cd $NOTES_PATH && vim'
function ,nweek() {
  if [[ ! -e "$WEEKNOTE_PATH" ]]; then
    echo "---
title: $(_,week)
date: $(_,first-weekday)
lastmod: $(_,today)
---

[<< Previous]({{< ref \"\" >}}) | Next >>

- ## Books being read
  - (pt-BR) Conversas Cruciais - Joseph Grenny & Kerry Patterson & Ron McMillan
    & Al Switzler & Emily Gregory
  - (pt-BR) História da Igreja: marcas da presença de Cristo no mundo - Angela
    Pellicciari
  - (pt-BR) História bíblica: narrativas do Antigo e do Novo Testamento - Dom
    Antônio de Macedo Costa

- ## Discovered tools
  -

- ## Learned
  -

- ## Read articles
  -

- ## Read news
  -

- ## Skimmed
  -

- ## Watched
  -

- ## Listened
  -

[<< Previous]({{< ref \"\" >}}) | Next >>
" > "$WEEKNOTE_PATH"
  fi
  cd "$NOTES_PATH"
  vim "$WEEKNOTE_PATH"
}
function ,nnew() {
  TITLE="$@"
  FILE="$NOTES_PATH/$TITLE.md"
  echo "---
title: $TITLE
date: $(_,today)
lastmod: $(_,today)
---" > "$FILE"
  cd "$NOTES_ROOT_PATH"
  vim "$FILE"
}

# python
alias ,py-venv='source .venv/bin/activate || python -m venv .venv && source .venv/bin/activate'
## poetry
alias ,pp-shell='poetry env activate'
poetry completions zsh >| "$ZSH_CACHE_DIR/completions/_poetry" &|
## django
alias ,dj='poetry run python manage.py'
alias ,djcreatesuperuser="DJANGO_SUPERUSER_PASSWORD=12345678 poetry run python manage.py createsuperuser --username lucas --email lucas@cezimbra.tec.br --noinput"
alias ,djshell='poetry run python manage.py shell_plus --ipython'

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

# OCR
alias ,ocr="llm -m gpt-4o 'OCR this image. Return ONLY the text.' -a"
function ,ocr-clipboard() {
  FILEPATH=${1:-"/tmp/$(date +%s).png"}
  xclip -selection clipboard -t image/png -o > $FILEPATH
  ,ocr $FILEPATH
}

# Wallpapers
function ,wallpaper-download() {
  NUMBER=$(python -c 'import random; print(random.randint(1, 52410))')
  IMG_URL=$(curl -s "https://peapix.com/bing/$NUMBER" | pup 'div.gallery-item attr{data-src}')
  curl "$IMG_URL" -o ~/Pictures/wallpapers/$NUMBER.jpg
}

. ~/.dotfiles/zshrc.local
