# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

# Oh my zsh
export ZSH=~/.oh-my-zsh
export EDITOR='vim'

ZSH_THEME="af-magic"
plugins=(autojump heroku git gitignore gulp pip pyenv python virtualenv)

source $ZSH/oh-my-zsh.sh


# experiments
alias cat=batcat
alias ls=exa
alias grep=rg

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
alias pmanage='poetry run python $PWD/manage.py'

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

function vpn() {
  nmcli connection delete pvpn-ipv6leak-protection
  protonvpn-cli c --cc BR
}

# zoxide
_z_cd() {
    cd "$@" || return "$?"

    if [ "$_ZO_ECHO" = "1" ]; then
        echo "$PWD"
    fi
}

z() {
    if [ "$#" -eq 0 ]; then
        _z_cd ~
    elif [ "$#" -eq 1 ] && [ "$1" = '-' ]; then
        if [ -n "$OLDPWD" ]; then
            _z_cd "$OLDPWD"
        else
            echo 'zoxide: $OLDPWD is not set'
            return 1
        fi
    else
        _zoxide_result="$(zoxide query -- "$@")" && _z_cd "$_zoxide_result"
    fi
}

zi() {
    _zoxide_result="$(zoxide query -i -- "$@")" && _z_cd "$_zoxide_result"
}

alias za='zoxide add'

alias zq='zoxide query'
alias zqi='zoxide query -i'

alias zr='zoxide remove'
zri() {
    _zoxide_result="$(zoxide query -i -- "$@")" && zoxide remove "$_zoxide_result"
}


_zoxide_hook() {
    zoxide add "$(pwd -L)"
}

chpwd_functions=(${chpwd_functions[@]} "_zoxide_hook")
alias cd=z
alias j=z

. ~/.dotfiles/zshrc.local
