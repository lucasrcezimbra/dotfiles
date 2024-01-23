# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

# Oh my zsh
export ZSH=~/.oh-my-zsh
export EDITOR='vim'

ZSH_THEME="af-magic"
plugins=(
  bgnotify
  colored-man-pages
  command-not-found
  copybuffer
  copyfile
  copypath
  extract
  gitfast
  gitignore
  globalias
  hasura
  mise
  per-directory-history
  pip
  poetry
  pyenv
  python
  qrcode
  ripgrep
  safe-paste
  starship
  terraform
  ufw
  universalarchive
  urltools
  virtualenv
  web-search
  yarn
  zoxide
)

source $ZSH/oh-my-zsh.sh

# experiments
alias ls=exa
alias grep=rg

# files
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'

# aws
alias av='aws-vault'
alias ave='aws-vault exec'
alias avl='aws-vault login'

# neovim
alias vim=lvim
alias v=lvim
export PATH="$HOME/.local/bin:$PATH"

# snap
export PATH="/snap/bin:$PATH"

# git
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gd='git diff'
alias gs='git status'
alias gig='gi'

# navigation
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias cd=z
alias j=z

# python
alias sa='source .venv/bin/activate'
alias manage='python $VIRTUAL_ENV/../manage.py'
alias pmanage='poetry run python $PWD/manage.py'

function n(){
  if [ $1 ]; then
    thunar $1 2> /dev/null
  else
    thunar $PWD 2> /dev/null
  fi
}

alias calc="python -c \"import sys; print(eval(''.join(sys.argv[1:])))\"" 
alias c=calc

GLOBALIAS_FILTER_VALUES=(calc ls pip)

export CHROME_BIN=chromium

# Docker
alias ,dockerkillall="docker ps -q | xargs docker kill"
function elasticsearch() {
    NAME="elasticsearch"
    docker start $NAME
    if [ $? -ne 0 ]; then
        docker run -d -p 9200:9200 -p 9300:9300 -e \"discovery.type=single-node\" --name=$NAME elasticsearch:7.6.2
    fi
}

function mongod() {
    NAME="mongo4"
    docker start $NAME
    if [ $? -ne 0 ]; then
        docker run -d -p=27017:27017 --name=$NAME mongo:4.0
    fi
}

function mongodreplica() {
    NAME="mongo4replica"
    docker start $NAME
    if [ $? -ne 0 ]; then
        docker run -d -p=27017:27017 --name=$NAME mongo:4.0 mongod --replSet replocal
        docker exec -it $NAME mongo --eval 'rs.initiate({_id: "replocal", members: [{_id: 0, host: "127.0.0.1:27017"}] })'
    fi
}

function vpn() {
  nmcli connection delete pvpn-ipv6leak-protection
  protonvpn-cli c --cc BR
}

. ~/.dotfiles/zshrc.local
