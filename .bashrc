[[ $- = *i* ]] && bind TAB:menu-complete

cd ~/code/icm-ui

if [ -e $HOME/.bash_aliases ]; then
    source $HOME/.bash_aliases
fi

alias testdb='ping -n 1 10.115.81.16'
alias ls='ls -F'
alias ll='ls -lh'
alias yyp='yarn && yarn prepare'