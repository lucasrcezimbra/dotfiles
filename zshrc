# snap
export PATH="/snap/bin:$PATH"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

export ZSH=~/.oh-my-zsh
export EDITOR='vim'

ZSH_THEME="af-magic"
plugins=(autojump heroku git gitignore gulp pip pyenv python virtualenv)

source $ZSH/oh-my-zsh.sh

# terminal style
export RPROMPT="\$(date +%H:%M:%S) $RPROMPT"

# git
alias ga='git add'
alias gc='git commit'
alias gs='git status'

# navigation
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'

# python
alias sa='source .venv/bin/activate'
alias manage='python $VIRTUAL_ENV/../manage.py'

function n(){
  if [ $1 ]; then
    thunar $1 2> /dev/null
  else
    thunar $PWD 2> /dev/null
  fi
}

function gig() {
	curl -L -s https://www.gitignore.io/api/$1 ;
}

function tg() {
	curl -X POST -d "{\"text\":\"$*\"}" https://integram.org/cneD5wITETV
}


alias calc="python -c \"import sys; print(eval(''.join(sys.argv[1:])))\"" 
alias c=calc

alias weather='curl wttr.in/Porto+Alegre'

alias pysort="git status -s | cut -d ' ' -f 3 | xargs isort"
alias pyflake="git status -s | grep '.py' | cut -d ' ' -f 3 | xargs flake8"
alias pyblack="git status -s | grep '.py' | cut -d ' ' -f 3 | xargs black"

export CHROME_BIN=chromium

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

. ~/.dotfiles/zshrc.local
