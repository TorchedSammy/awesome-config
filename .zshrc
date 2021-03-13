export PATH=$PATH:$HOME/bin:/usr/local/bin:/usr/local/go/bin:$HOME/go/bin:/sbin
#PROMPT="%(!.%{%B%F{red}%}.%{%B%F{green}%})→ %n@%m %{%B%F{blue}%}%2~ %(!.Λ.λ)%f%b "
PROMPT="%{%B%F{white}%}%(!.Λ.λ) %{%B%F{cyan}%}%2~ %(!.%{%B%F{green}%}>%{%B%F{cyan}%}>%{%B%F{green}%}>.%{%B%F{cyan}%}>%{%B%F{magenta}%}>%{%B%F{cyan}%}>)%f%b "

autoload -U compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# History
HISTSIZE=1000
HISTFILE=~/.histzsh
SAVEHIST=5000

setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt share_history

autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end

export EDITOR='nvim'

# Aliases
alias ls='ls -a'
alias cls='clear'
alias cava='cava-wrapper'
alias nu='nvm use node'

# NVM install
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh" --no-use # This loads nvm
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

