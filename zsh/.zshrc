# Resolving the issue of "complete:13: command not found: compdef"
# https://stackoverflow.com/questions/66338988/complete13-command-not-found-compdef
autoload -Uz compinit
compinit

# Starship
eval "$(starship init zsh)"

# zoxide 
eval "$(zoxide init zsh)"

# Activate syntax highlighing
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 

# Disable underline 
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none 

# Activate autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# My Alias 
alias vim=nvim
alias create_project="/usr/local/bin/create_project.sh"
alias ls=eza
alias cd=z

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/usr/local/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/usr/local/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Add Docker Desktop to PATH if not already present
if [[ ":$PATH:" != *":/Applications/Docker.app/Contents/Resources/bin:"* ]]; then
    export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin"
fi
. "$HOME/.local/bin/env"
# START: Added by Updated Airflow Breeze autocomplete setup
source "/Users/yimingpeng/pCloud/02 - Areas/My_Work/open-source/airflow/dev/breeze/autocomplete/breeze-complete-zsh.sh"
# END: Added by Updated Airflow Breeze autocomplete setup