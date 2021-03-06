# update dotfiles from repo
function update_dots () {
  git -C ~/src pull
  bash ~/src/install_dotfiles.sh
  source ~/.bashrc
}

if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:($debian_chroot)}\[\e[93m\]\W\[\e[m\]:/\[\e[34m\]>\[\e[m\]\[\e[37m\]\\$\[\e[m\] '
else
  PS1='${debian_chroot:($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# Journaling alias
alias note='sh ~/Documents/dotfiles/journal.sh $*'

# copy trajectory files
alias copy_trajectory_files='cp /mnt/sun-pcp01/kcaldwell/*.pmc ~/driving/vehicle/pseudo_planner/trajectory_converter/abd_files/trajectory_files/'

# additional flags for python plotting with bazel
alias pyplot='bazel run --//tools/python:enable_in_build_python=false'

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

gh() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -'$LINES |
  grep -o "[a-f0-9]\{7,\}"
}

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
  local commit
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

# search driving directory, but ignore experimental directory
function ds () {
  if [ "$#" -eq  "0" ]
    then
      echo "No arguments supplied"
  else
      git grep -n -r -i -I --files-with-matches --exclude-standard --untracked ${@:2} "$1"
  fi
}

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

