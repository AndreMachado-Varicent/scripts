alias ls='ls -F'
#alias ll='ls -lh'

alias yyp='yarn && yarn prepare'
alias yypf='yarn && yarn prepare:force'
alias ys='yarn start'

alias ts='cd ~/code/icm-cloud/packages/tenant-services && npm run simple'
alias killnode='cmd "/C TASKKILL /IM node.exe /F"'

# create a branch to resolve conflicts between release and release2
alias ccc12='git stash;git co release; git pull; git co release2; git pull;  git co -b resolve-conflicts-`date +%s`; git merge --no-ff origin/release;'

# create a branch to resolve conflicts between production and release
alias cccp1='git stash;git co production; git pull; git co release; git pull;  git co -b resolve-conflicts-`date +%s`; git merge --no-ff origin/production;'

# create a branch to resolve conflicts between release2 and exp
alias ccc2exp='git stash;git co release2; git pull; git co exp; git pull;  git co -b resolve-conflicts-`date +%s`; git merge --no-ff origin/release2;'

# delete all local branches that have been deleted on remote
alias delGone="git fetch --all --prune; git branch -vv | awk '/: gone]/{print $1}' | xargs -r git branch -D"

