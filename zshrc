HISTSIZE=10000000
SAVEHIST=10000000

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

# paths
NOTES_ROOT_PATH="$HOME/workspace/lucasrcezimbra.github.io"
DOTFILES_PATH="$HOME/.dotfiles"
NOTES_PATH="$NOTES_ROOT_PATH/content/anotacoes"

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
## poetry
poetry completions zsh >| "$ZSH_CACHE_DIR/completions/_poetry" &|

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

# Wallpapers
function ,wallpaper-download() {
  NUMBER=$(python -c 'import random; print(random.randint(1, 52410))')
  IMG_URL=$(curl -s "https://peapix.com/bing/$NUMBER" | pup 'div.gallery-item attr{data-src}')
  curl "$IMG_URL" -o ~/Pictures/wallpapers/$NUMBER.jpg
}

. ~/.dotfiles/shellrc
. ~/.dotfiles/zshrc.local
