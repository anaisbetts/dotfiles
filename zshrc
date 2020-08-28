HISTFILE=~/.zhistory
HISTSIZE=5000
SAVEHIST=1000

bindkey -v
setopt appendhistory      # append to HISTFILE
setopt autocd             # go to directories without "cd"
setopt extendedglob       # wacky zsh-specific pattern matching

fpath=( "$HOME/dotfiles/zfunctions" $fpath )

autoload -U promptinit; promptinit
prompt pure

# cache completions (useful for apt/dpkg package completions)
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# aliases
alias mv='nocorrect mv'       # no spelling correction on mv
alias cp='nocorrect cp'
alias mkdir='nocorrect mkdir'
alias j=jobs
if ls -F --color=auto >&/dev/null; then
  alias ls="ls --color=auto -F"
else
  alias ls="ls -F"
fi
alias ll="ls -l"
alias l.='ls -d .[^.]*'
alias lsd='ls -ld *(-/DN)'
alias md='mkdir -p'
alias rd='rmdir'
alias cd..='cd ..'
alias ..='cd ..'
alias po='popd'
alias pu='pushd'
alias tsl="tail -f /var/log/syslog"
alias df="df -hT"
alias grep='grep --color=tty -d skip'
alias less="less -R"
alias qlf='qlmanage -p "$@" >& /dev/null'
alias be="bundle exec"
alias tmux="TERM=screen-256color-bce tmux"

zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals.*'  insert-sections   true
zstyle ':completion:*:man:*'      menu yes select

export EDITOR="vim"

export CLICOLOR="true"

source "$HOME/dotfiles/zfunctions/completion_fzf"
source "$HOME/dotfiles/zfunctions/keybindings_fzf"

mach="$(uname -m)"
export PATH="$PATH:$HOME/dotfiles/bin:$HOME/dotfiles/bin/$mach"

export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd -t d ."
