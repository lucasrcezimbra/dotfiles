export ZSH=/home/lucas/.oh-my-zsh
export EDITOR='vim'

ZSH_THEME="af-magic"
plugins=(autojump heroku git gitignore gulp pip pyenv python virtualenv)

source $ZSH/oh-my-zsh.sh

# pyenv
export PATH="/home/lucas/.pyenv/bin:$PATH"
eval "$(pyenv init - zsh)"
eval "$(pyenv virtualenv-init -)"

# alias
# gulp
alias gub='gulp build'
alias guw='gulp watch'
# alias git=hub
eval "$(hub alias -s)"
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
    nautilus $1 2> /dev/null
  else
    nautilus $PWD 2> /dev/null
  fi
}

function gig() {
	curl -L -s https://www.gitignore.io/api/$1 ;
}

function tg() {
	curl -X POST -d "{\"text\":\"$*\"}" https://integram.org/cneD5wITETV
}
