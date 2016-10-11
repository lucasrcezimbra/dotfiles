export ZSH=/home/lucas/.oh-my-zsh
export EDITOR='vim'

ZSH_THEME="af-magic"
plugins=(autojump heroku git gitignore gulp pip pyenv python virtualenv)

source $ZSH/oh-my-zsh.sh

# pyenv
export PATH="/home/lucas/.pyenv/bin:$PATH"
eval "$(pyenv init - zsh)"
eval "$(pyenv virtualenv-init -)"

function n(){
  if [ $1 ]; then
    nautilus $1 2> /dev/null
  else
    nautilus $PWD 2> /dev/null
  fi
}

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
