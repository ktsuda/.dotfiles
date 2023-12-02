bindkey -e

case ${OSTYPE} in
  darwin*)
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
    ;;
  linux*)
    export LC_ALL=en_US.utf8
    export LANG=en_US.utf8
    export LANGUAGE=en_US.utf8
    ;;
esac

# prevent zsh from exit with ctrl-d key
setopt IGNOREEOF
# share history, avoid duplication
setopt share_history
setopt hist_reduce_blanks
setopt hist_ignore_all_dups
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

export VISUAL=nvim
export EDITOR=nvim

setopt auto_pushd
setopt pushd_ignore_dups

# disable lock/unlock with ctrl-s/ctrl-q
setopt no_flow_control

typeset -U path PATH

path=(
  ~/.fzf/bin(N-/)
  ~/bin(N-/)
  ~/.rbenv/bin(N-/)
  ~/.local/share/nvim/mason/bin(N-/)
  ~/go/bin(N-/)
  /usr/local/go/bin(N-/)
  ~/.cargo/bin(N-/)
  ~/.local/bin(N-/)
  ~/.yarn/bin(N-/)
  ~/Library/Python/3.9/bin(N-/)
  ~/.config/yarn/global/node_modules/bin(N-/)
  ~/.deno/bin(N-/)
  /usr/local/bin(N-/)
  /usr/bin
  /usr/sbin
  /bin
  /sbin
  /usr/local/sbin(N-/)
  /opt/local/bin(N-/)
  /Library/Apple/usr/bin(N-/)
  $path
)

case ${OSTYPE} in
  darwin*)
    eval "$(/opt/homebrew/bin/brew shellenv)"
    ;;
esac

typeset -U fpath

fpath=(
  /opt/homebrew/share/zsh-completions(N-/)
  /opt/homebrew/share/zsh/site-functions(N-/)
  ~/.config/zsh/zsh-completions(N-/)
  $fpath
)

# git clone https://github.com/zsh-users/zsh-autosuggestions \
#   ~/.zsh/zsh-autosuggestions
if [ -f "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

autoload -Uz compinit; compinit

if type zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

if [ -x "$HOME/.rbenv/bin/rbenv" ]; then
  eval "$($HOME/.rbenv/bin/rbenv init - zsh)"
fi

export GOPATH="$HOME/go"
export GOBIN="$HOME/go/bin"
export GO11MODULE="auto"

PROMPT='%1~ $ '
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats '%b'

case ${OSTYPE} in
  darwin*)
    if type exa &>/dev/null; then
      alias ls='exa -F -g --color=automatic'
      alias la='ls -a'
      alias ll='ls -l -s date --time-style long-iso'
      alias lla='ll -a'
    elif type gls &>/dev/null; then
      alias ls='gls -X -F -C -T 2 --color=auto'
      alias la='ls -a'
      alias ll='ls -lrt'
      alias lla='ll -a'
    else
      alias ls='ls -F -C -G'
      alias la='ls -a'
      alias ll='ls -lrt'
      alias lla='ll -a'
    fi

    if type fd &>/dev/null; then
      alias fd='fd --hidden --exclude .git'
      alias f='${EDITOR} $(fd -t f -t l|$(__fzfcmd))'
    fi
    ;;
  linux*)
    if type exa &>/dev/null; then
      alias ls='exa -F -g --color=automatic'
      alias la='ls -a'
      alias ll='ls -l -s date --time-style long-iso '
      alias lla='ll -a'
    else
      alias ls='ls -X -F -C -T 2 --color=auto'
      alias la='ls -a'
      alias ll='ls -lrt'
      alias lla='ll -a'
    fi

    if type fdfind &>/dev/null; then
      alias fd='fdfind --hidden --exclude .git'
    fi
    ;;
esac

if type bat &>/dev/null; then
  alias cat='bat --color=always --theme="Nord"'
fi

if type rg &>/dev/null; then
  alias rg='rg -H --column -n -S --no-heading -uu -g !.git'
fi

if type dust &>/dev/null; then
  alias du='dust -X .git'
fi

if type xh &>/dev/null; then
  alias wget='xh --download'
fi

if type pbcopy &>/dev/null; then
elif type xsel &>/dev/null; then
  alias pbcopy='xsel --clipboard --input'
elif type xclip &>/dev/null; then
  alias pbcopy='xclip -selection c'
else
  echo 'Install xclip or xsel'
fi

alias rm='rm -i'
alias cp='cp -ip'
alias mv='mv -i'

alias gl='git l'
alias gb='git branch -av'
alias gs='git status -sb'
alias gd='git diff'
alias ga='git add -N . && git add -p'
alias gc='git commit -s -v'
alias gco='git checkout'
alias gp='git push origin'

alias dp='docker container ls'
alias di='docker image ls'
alias dv='docker volume ls'
alias dn='docker network ls'
alias drmp='docker rm $(dp -q -f "status=exited")'
alias drmi='docker rmi $(di -q -f "dangling=true")'

alias t='tig'
alias ta='tig --all'
alias ts='tig status'
alias tx='tmuxinator'

alias r='ranger'

alias v='nvim'
alias vim='nvim'
alias vc='nvim --clean'
alias vimc='nvim --clean'
alias vimdiff='nvim -d'
alias m='v $HOME/memo.md'

alias q='goto_repo_root'
function goto_repo_root() {
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    cd $(git rev-parse --show-toplevel)
  fi
}

function chdir_parent() {
  echo
  cd ..
  zle accept-line
}
zle -N chdir_parent
bindkey '^u' chdir_parent

function __fzfcmd() {
  [ -n "$TMUX_PANE" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "$FZF_TMUX_OPTS" ]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

function git-repo-cd() {
  local selected_dir=$(ghq list --full-path | \
    FZF_DEFAULT_OPTS='--height 40% --reverse +m' $(__fzfcmd))
  local ret=$?
  if [ -z "$selected_dir" ]; then
    zle redisplay
    return 0
  fi
  eval "builtin cd -- ${selected_dir}"
  zle reset-prompt
  return $ret
}
zle -N git-repo-cd
bindkey "^s" git-repo-cd

function subdir-cd() {
  local selected_dir
  if type fd &>/dev/null; then
    local selected_dir=$(fd -t d --hidden | \
      FZF_DEFAULT_OPTS='--height 40% --reverse +m' $(__fzfcmd))
  else
    local selected_dir=$(find . -type d | \
      FZF_DEFAULT_OPTS='--height 40% --reverse +m' $(__fzfcmd))
  fi
  local ret=$?
  if [ -z "$selected_dir" ]; then
    zle redisplay
    return 0
  fi
  eval "builtin cd -- ${selected_dir}"
  zle reset-prompt
  return $ret
}
zle -N subdir-cd
bindkey "^o" subdir-cd

function history-widget() {
  local selected num
  selected=($(fc -rl 1 | FZF_DEFAULT_OPTS='--height 40% --reverse +m' $(__fzfcmd)))
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle reset-prompt
  return $ret
}
zle -N history-widget
bindkey "^r" history-widget

alias ipv4='ipv4_address'
function ipv4_address() {
  local ipv4_address=$(ifconfig | \
    awk '$0 ~ /inet\ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/{ print $2 }' | \
    FZF_DEFAULT_OPTS='--height 40% --reverse +m' $(__fzfcmd))
  local ret=$?
  if [ -z "$ipv4_address" ]; then
    return 0
  fi
  echo "$ipv4_address"
  return $ret
}

alias sp='pkg-search'
function pkg-search() {
  local selected_pkg=$(dpkg -l | \
    awk '/^ii/ { print $2 }' | \
    FZF_DEFAULT_OTS='--height 40% --reverse +m' $(__fzfcmd))
  local ret=$?
  if [ -z "$selected_pkg" ]; then
    return 0
  fi
  apt-cache depends $selected_pkg
  echo
  apt-cache rdepends $selected_pkg
  return $ret
}

function custom_tmux_session() {
  if [[ "$#" -ge 1 ]]; then
    ID="$1"
    if [[ -n $TMUX ]]; then
      tmux new-session -d -s"$ID"
      tmux switch-client -t "$ID"
    else
      tmux new-session -s"$ID"
    fi
  else
    ID="`tmux list-sessions 2>/dev/null | $(__fzfcmd) -0 | cut -d: -f1`"
    if [[ -z "$ID" ]]; then
      tmux new-session -s "default"
      return
    fi
    if [[ -n $TMUX ]]; then
      tmux switch-client -t "$ID"
    else
      tmux attach-session -t "$ID"
    fi
  fi
}

function custom_send_to_session() {
  if [[ "$#" -lt 1 ]]; then
    return
  fi
  ID="`tmux list-sessions 2>/dev/null | $(__fzfcmd) -0 | cut -d: -f1`"
  if [[ -z "$ID" ]]; then
    tmux new-session -s "default" tmux new-window -t "default" "$*"
    return
  fi
  tmux new-window -t "$ID" "$*"
}

if type tmux > /dev/null 2>&1; then
  alias s='custom_tmux_session'
  alias a='custom_send_to_session'
elif type screen > /dev/null 2>&1; then
  alias s='screen'
else
  ;
fi

if [ ! -f ~/.zshrc.zwc -o ~/.zshrc -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi
