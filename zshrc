export ZSH=/home/lucas/.oh-my-zsh
export EDITOR='vim'

ZSH_THEME="robbyrussell"
plugins=(autojump heroku git gitignore gulp pip pyenv python virtualenv)

source $ZSH/oh-my-zsh.sh

# pyenv
export PATH="/home/lucas/.pyenv/bin:$PATH"
eval "$(pyenv init - zsh)"
eval "$(pyenv virtualenv-init -)"

# navigation alias
alias ~='cd ~'
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'

# alias git=hub
eval "$(hub alias -s)"

function n(){
  if [ $1 ]; then
    nautilus $1 >> /dev/null
  else
    nautilus $PWD >> /dev/null
  fi
}
