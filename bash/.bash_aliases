alias ls='ls -F'
#alias ll='ls -lh'

alias yyp='yarn && yarn prepare'
alias yypf='yarn && yarn prepare:force'
alias ys='yarn start'

alias ts='cd ~/code/icm-cloud/packages/tenant-services && npm run simple'
alias killnode='cmd "/C TASKKILL /IM node.exe /F"'

function check_git_repo() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        return 1
    fi
}

function check_pending_merge() {
    if [ -f .git/MERGE_HEAD ]; then
        return 1
    fi
}

# Resolve conflicts between two branches.
#
# Parameters:
#   branch - The branch to merge into.
#   merge_branch - The branch to merge from.
#   new_branch_suffix - The suffix to append to the new branch name.
function resolve_conflicts() {
    if ! check_git_repo; then
        echo "Not a git repository. Exiting..." >&2
        return
    fi

    if ! check_pending_merge; then
        echo "There is a pending merge. Exiting..." >&2
        return
    fi

    local branch=$1
    local merge_branch=$2
    local new_branch_suffix=$3

    set -e
    git stash
    git fetch -p
    git checkout $branch
    git pull
    git checkout -b resolve-conflicts-$new_branch_suffix-$(date +%s)
    git merge --no-ff origin/$merge_branch
}

function conflicts12() {
    resolve_conflicts "release2" "release" "release-release2"
}

function conflictsp1() {
    resolve_conflicts "release" "production" "production-release"
}

function conflicts2exp() {
    resolve_conflicts "exp" "release2" "release2-exp"
}

# Delete branches that are no longer on the remote.
function delGone() {
    if ! check_git_repo; then
        echo "Not a git repository. Exiting..." >&2
        return
    fi

    set -e
    git fetch --all --prune
    git branch -vv | awk '/: gone]/{print $1}' | xargs -r git branch -D
}


alias ccc12='conflicts12'
alias cccp1='conflictsp1'
alias ccc2exp='conflicts2exp'

alias delGone='delGone'

alias var='cd ~/code/Varicent'
alias icmui='cd ~/code/icm-ui'

