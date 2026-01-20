HISTSIZE=10000000
SAVEHIST=10000000

# pipx
export PATH="$HOME/.local/bin:$PATH"

# Oh my zsh
export ZSH=~/.oh-my-zsh
export EDITOR='nvim'

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
alias ,notes='cd $NOTES_PATH && $EDITOR'
function ,nweek() {
  if [[ ! -e "$WEEKNOTE_PATH" ]]; then
    echo "---
title: $(_,week)
date: $(_,first-weekday)
lastmod: $(_,today)
---

<< Previous | Next >>

- ## Books being read
  -

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

<< Previous | Next >>
" > "$WEEKNOTE_PATH"
  fi
  cd "$NOTES_PATH"
  $EDITOR "$WEEKNOTE_PATH"
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
  $EDITOR "$FILE"
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

# Wallpapers
function ,wallpaper-download() {
  NUMBER=$(python -c 'import random; print(random.randint(1, 52410))')
  IMG_URL=$(curl -s "https://peapix.com/bing/$NUMBER" | pup 'div.gallery-item attr{data-src}')
  curl "$IMG_URL" -o ~/Pictures/wallpapers/$NUMBER.jpg
}

. ~/.dotfiles/shellrc
. ~/.dotfiles/zshrc.local
