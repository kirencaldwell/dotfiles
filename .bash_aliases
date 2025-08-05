# update dotfiles from repo
function update_dots () {
  git -C ~/src pull
  bash ~/src/install_dotfiles.sh
  source ~/.bashrc
}

/home/kcaldwell/Documents/dotfiles/setup_tmux_workspaces.sh

setup_machine() {
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

cp ~/.tmux.conf ~/.tmux.conf.bak
cp ~/Documents/dotfiles/.tmux.conf ~/.tmux.conf
set -o vi

alias summarize_commits='/home/kcaldwell/Documents/dotfiles/summarize_commits.py'
# Function to ensure commit summary cron job is installed
setup_commit_summary_cron() {
    # Check if the cron job already exists
    if ! crontab -l 2>/dev/null | grep -q "summarize_commits"; then
        # If it doesn't exist, add it
        (crontab -l 2>/dev/null; echo "55 23 * * * 'summarize_commits'") | crontab -
        echo "Commit summary cron job installed"
    else
      echo "Summarize commit cron job already exists"
    fi
}
# Run the setup function when .bash_aliases is sourced
setup_commit_summary_cron  

alias clean_chum_cache='find /home/kcaldwell/.cache/chum -type d -mtime +60 -exec rm -rf {} +'
alias find_all_argus='/home/kcaldwell/Documents/dotfiles/find_link_tmux.sh'
alias find_last_argus='/home/kcaldwell/Documents/dotfiles/find_link_tmux.sh | tail -1'
alias argus_obs='/home/kcaldwell/Documents/dotfiles/format_pr_obs.py -l $(find_last_argus) -o $@'
alias gcm='zi-gcm --dry-run | xclip -selection clipboard'
alias copy='xclip -selection clipboard'

alias grc='git rebase --continue'
alias gca='git commit --amend'
alias gsp0='git stash pop stash@{0}'
alias gh='./devx/bin/gh'

git_workflow() {
  echo "Setup stack: git checkout --track origin/master -b kcaldwell/project_name"
  echo "Make changes"
  echo "Make commit message and copy to clibpard: gcm"
  echo "Commit changes: git commit"
  echo "Paste commit message"
  echo "Test things"
  echo "Log observations from Argus and copy to clipboard: argus_obs obs1 obs2 | copy"
  echo "Add observations to PR: gca"
  echo "Paste observations"
}
split_commit() {
  echo "Splitting commit 'git reset HEAD^'"
  git reset HEAD^
  echo "Now add files and make commits to split into multiple commits"
}

# Show git branch name
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
# Update terminal title with git branch
PROMPT_COMMAND='echo -ne "\033]0;${PWD##*/}$(parse_git_branch)\007"' 

alias cs='git grep -ni $*'
alias md2html='function _md2html() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: md2html input.md output.html"
        return 1
    fi
    if [ ! -f "$1" ]; then
        echo "Error: Input file $1 not found"
        return 1
    fi
    pandoc "$1" -o "$2" -s --css style.css
    # Get absolute path and create file URL
    abs_path=$(realpath "$2")
    echo "Conversion complete. Click here to open: file://$abs_path"
}; _md2html' 

alias nodejs=node

# Journaling alias
alias note='sh ~/Documents/dotfiles/journal.sh $*'

# Results alias
alias results='sh ~/Documents/dotfiles/save_results.sh $*'

# debug
alias debug='$(pwd)/devx/scripts/debug.py'

# refresh zooxrc
function refresh_zooxrc () {

  eval '(ssh-agent)'
  eval '(ssh-add -k ~/.ssh/id_ed25519)'
  if test -f scripts/shell/zooxrc.sh; then
    echo "Refreshing zooxrc"
    source scripts/shell/zooxrc.sh
  fi
}

# 
alias vimf='vim $(fzf)'

# ssh shortcuts

# Credit: https://github.com/junegunn/fzf/wiki/examples#git
# With small modifications
# git fzf bindings
# GIT heart FZF
# -------------


is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

fzf-down() {
  fzf --height 50% "$@" --border
}

gf() {
  is_in_git_repo || return
  git -c color.status=always status --short |
  fzf-down -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
  cut -c4- | sed 's/.* -> //'
}

gb() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-down --multi --preview-window right:70% \
    --preview 'git show --color=always {} | head -'$LINES
}

#gh() {
#  is_in_git_repo || return
#  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
#  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
#    --header 'Press CTRL-S to toggle sort' \
#    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -'$LINES |
#  grep -o "[a-f0-9]\{7,\}"
#}

gr() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-down --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1} | head -200' |
  cut -d$'\t' -f1
}

# fgbr - checkout git branch (including remote branches)
fgbr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# fco - checkout git branch/tag
fco() {
  local tags branches target
  branches=$(
    git --no-pager branch --all \
      --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%1B[0;34;1mbranch%09%1B[m%(refname:short)%(end)%(end)" \
    | sed '/^$/d') || return
  tags=$(
    git --no-pager tag | awk '{print "\x1b[35;1mtag\x1b[m\t" $1}') || return
  target=$(
    (echo "$branches"; echo "$tags") |
    fzf --no-hscroll --no-multi -n 2 \
        --ansi) || return
  git checkout $(awk '{print $2}' <<<"$target" )
}


# fco_preview - checkout git branch/tag, with a preview showing the commits between the tag/branch and HEAD
fco_preview() {
  local tags branches target
  branches=$(
    git --no-pager branch --all \
      --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%1B[0;34;1mbranch%09%1B[m%(refname:short)%(end)%(end)" \
    | sed '/^$/d') || return
  tags=$(
    git --no-pager tag | awk '{print "\x1b[35;1mtag\x1b[m\t" $1}') || return
  target=$(
    (echo "$branches"; echo "$tags") |
    fzf --no-hscroll --no-multi -n 2 \
        --ansi --preview="git --no-pager log -150 --pretty=format:%s '..{2}'") || return
  git checkout $(awk '{print $2}' <<<"$target" )
}

# fcoc - checkout git commit
fcoc() {
  local commits commit
  commits=$(git log --pretty=oneline --abbrev-commit --reverse) &&
  commit=$(echo "$commits" | fzf --tac +s +m -e) &&
  git checkout $(echo "$commit" | sed "s/ .*//")
}

# fshow - git commit browser
fshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}
alias glNoGraph='git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr% C(auto)%an" "$@"'
_gitLogLineToHash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
_viewGitLogLine="$_gitLogLineToHash | xargs -I % sh -c 'git show --color=always % | diff-so-fancy'"

# fcoc_preview - checkout git commit with previews
fcoc_preview() {
  local commt
  commit=$( glNoGraph |
    fzf --no-sort --reverse --tiebreak=index --no-multi \
        --ansi --preview="$_viewGitLogLine" ) &&
  git checkout $(echo "$commit" | sed "s/ .*//")
}

# fshow_preview - git commit browser with previews
fshow_preview() {
    glNoGraph |
        fzf --no-sort --reverse --tiebreak=index --no-multi \
            --ansi --preview="$_viewGitLogLine" \
                --header "enter to view, alt-y to copy hash" \
                --bind "enter:execute:$_viewGitLogLine   | less -R" \
                --bind "alt-y:execute:$_gitLogLineToHash | xclip"
}



## Checkout from local branches
alias flgc="git for-each-ref --format='%(refname:short)' refs/heads | fzf | xargs git checkout"
## Checkout from all branches (local/remote)
alias fgc="gb | xargs git checkout"

# Pull Request Check Out - check out pull request branches (no arg sets the target to develop/planner) from GitHub.
# You can provide the target branch with `pr_co BRANCH` for example `pr_co master` will show you the list of PRs into master and you can fuzzy search within the dropdown and choose a PR to checkout.
pr_co() {
    local name="${1:-"develop/planner"}";
    hub pr list --base $name --format="%i | %au | %sC %pS | %t [%H] | %U%n" | fzf --ansi | egrep -o '[[:digit:]]+' | head -n 1 | xargs hub pr checkout
}

# To fuzzy search within the current PRs into target branch (no arg sets the target to develop/planner) with the username of author, PR number, PR title, ... The urls can be controlled clicked if you terminal supports that. VSCode terminal supports that. This command can be used to just look at a PR without checking it out.
# You can provide the target branch `pr_show BRANCH` for example `pr_show master` will show you the list of PRs into master and you can fuzzy search within the dropdown and choose a PR.
pr_show() {
    local name="${1:-"develop/planner"}";
    hub pr list --base $name  --format="%i | %au | %sC %pS | %t [%H] | %U%n" | fzf --ansi | egrep -o '[[:digit:]]+' | head -n 1 | xargs hub pr show -uc
}

# To check the status of CI for PRs into target branch. Starts a drop down menu of all the PRs into the target branch (no arg sets the target to develop/planner)
pr_status() {
    local name="${1:-"develop/planner"}";
    hub pr list --base $name  --format="%sH %i | %au | %sC %pS | %t [%H] | %U%n" | fzf --ansi | sed 's/ .*//' | head -n 1 | xargs hub ci-status -v
}

# Auto completion of btest and bb and removing the trigger. This
# makes the tab to act as trigger.
# Credit: https://github.com/junegunn/fzf/wiki/Examples-(completion)
# Create a cache. Every time you checkout a branch with new targets, you should run
# update_bzc

_cache_bazel_query() {
    # create cache file if it does not exist
    cache_file="/tmp/bazel-modified-files-cache-all"
    if test ! -f "$cache_file"; then
        update_bzc
    fi
    cat /tmp/bazel-modified-files-cache-all
}

update_bzc() {
    bazel query '//...' > /tmp/bazel-modified-files-cache-all
    bazel query 'tests(//...)' > /tmp/bazel-modified-files-cache-tests
}

_cache_bazel_query_test() {
    # create cache file if it does not exist
    cache_file="/tmp/bazel-modified-files-cache-tests"
    if test ! -f "$cache_file"; then
        update_bzc
    fi
    cat /tmp/bazel-modified-files-cache-tests
}

_fzf_complete_bb() {
   value=$(cat /tmp/bazel-modified-files-cache)
  _fzf_complete "--multi --reverse --header-lines=3" "$@" < <(
  _cache_bazel_query)
}

_fzf_complete_brun() {
  _fzf_complete "--multi --reverse --header-lines=3" "$@" < <(
  _cache_bazel_query)
}

_fzf_complete_btest() {
  _fzf_complete "--multi --reverse --header-lines=3" "$@" < <(
  _cache_bazel_query_test)
}


[ -n "$BASH" ] && complete -F _fzf_complete_brun -o default -o bashdefault brun
[ -n "$BASH" ] && complete -F _fzf_complete_bb -o default -o bashdefault bb
[ -n "$BASH" ] && complete -F _fzf_complete_btest -o default -o bashdefault btest

_fzf_complete_btest_notrigger() {
    FZF_COMPLETION_TRIGGER='' _fzf_complete_btest
}
_fzf_complete_brun_notrigger() {
    FZF_COMPLETION_TRIGGER='' _fzf_complete_brun
}
_fzf_complete_bb_notrigger() {
    FZF_COMPLETION_TRIGGER='' _fzf_complete_bb
}

complete -o bashdefault -o default -F _fzf_complete_brun_notrigger brun
complete -o bashdefault -o default -F _fzf_complete_btest_notrigger btest
complete -o bashdefault -o default -F _fzf_complete_bb_notrigger bb

alias fbt="bazel query 'tests(//...)' | fzf | xargs bazel test"
alias fbr="bazel query '//...' | fzf | xargs bazel run"
alias fbb="bazel query '//...' | fzf | xargs bazel build"


# using ripgrep combined with preview
# find-in-file - usage: fif <searchTerm>
fif() {
  if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
  rg --files-with-matches --no-messages "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
}

# tmux shortcuts
alias tls='tmux list-sessions'
alias tks='tmux kill-session -t'
alias ta='tmux attach -t'
alias tn='TERM=xterm-256color tmux new -s'

function remove_project() {
  PWD_NAME=$(pwd)
  PROJ_NAME=$1
  cd ~/driving
  git worktree remove ../$PROJ_NAME
  git branch -D $PROJ_NAME
  git branch -D kcaldwell/$PROJ_NAME
  if [ $(tmux display-message -p '#S') = $PROJ_NAME ]; then
    tmux switch -t home
  fi 
  tmux kill-session -t $PROJ_NAME
}

function new_project () {
  PWD_NAME=$(pwd)
  PROJ_NAME=$1
  cd ~/driving
  git worktree add ../$PROJ_NAME
  cd ../$PROJ_NAME
  if [ -n "$2" ]; then
    BASE=$2
    git checkout --track $BASE -b $PROJ_NAME
  else
    git checkout --track origin/master -b $PROJ_NAME
  fi
  TMUX= tmux new-session -d -s $PROJ_NAME
  tmux switch-client -t $PROJ_NAME
  cd $PWD_NAME
}

function doxy () {
  CMD="./doc/doxygen/generate_doxygen.sh local_docs" 
  $CMD $1
  s=$1
  d=${s%%:*}
  my_ip=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')
  echo $my_ip":8000/"$d
  (cd local_docs; python3 -m http.server 8000)
}

function fzfc() {
  cat ~/saved_commands.txt | fzf
}

function save_last_command() {
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2> /dev/null);
  COMMAND=$(fc -ln -1);
  echo "\`$BRANCH\` $COMMAND"
  echo -e "\x60\x23 $BRANCH\x60 $COMMAND" >> ~/saved_commands.txt
}

function run_local_curvature_response() {
  ./sim/launch.sh local planner vis/controls_analysis/sim_tests:curvature_response --simulator_args="--params-kv sim/enable_cas=false --params-kv sim/terminate_on=none" --save_chum_nfs
}

function run_marvel_curvature_response() {
  ./sim/launch.sh marvel planner vis/controls_analysis/sim_tests:curvature_response --simulator_args="--params-kv sim/enable_cas=false --params-kv sim/terminate_on=none"
}

source /usr/share/doc/fzf/examples/key-bindings.bash


