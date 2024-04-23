[[ $- = *i* ]] && bind TAB:menu-complete

cd ~/code/icm-ui

if [ -e $HOME/.bash_aliases ]; then
    source $HOME/.bash_aliases
fi

export PROMPT_COMMAND='history -a'

#export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
