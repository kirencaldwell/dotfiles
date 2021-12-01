# update dotfiles from repo
function update_dots () {
  git -C ~/src pull
  bash ~/src/install_dotfiles.sh
  source ~/.bashrc 
}

# ssh shortcuts

# tmux shortcuts
alias tls='tmux list-sessions'
alias tks='tmux kill-session -t'
alias ta='tmux attach -t'
alias tn='tmux new -s'

function start_tmux () {
  tmux new-session -s 'home'
  tmux new-session -s 'hil'
  tmux new-session -s 'desktop'
} 

# sync logs
alias log_sync='rsync -rtP kcaldwell@controlhil-desktop.corp.nuro.team:/mnt/ssd ~/Documents/Logs'

function cdr () {
  cd ~/Documents/repos/"$1"
}
alias lsr='ls ~/Documents/repos/'

# code search
function cs () {
  if [ "$#" -eq  "0" ]
    then
      echo "No arguments supplied"
  else
      grep -n -r -i ${@:2} "$1"
  fi  
} 

# find files
function ff () { 
  if [ "$#" -eq "0" ]
  then
    echo "no arguments supplied"
  else
    find -iname \*$1\*
  fi
}

