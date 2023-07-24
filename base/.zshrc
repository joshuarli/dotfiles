alias sway='XDG_RUNTIME_DIR=/tmp/xdg sway'
alias tmux="tmux -f ${XDG_CONFIG_HOME}/tmux/tmux.conf"

alias ..='cd ..'
alias ls='ls -F --color=always -v'
alias l='ls -p'
alias ll='ls -plAhG'
alias e="$EDITOR"
alias fdh="fd --no-ignore-vcs -H -E '.git/'"
alias rg="rg -S"
alias rgh="rg --hidden -S -g '!.git'"
alias tl='tmux ls'
alias tn='tmux new -s'
alias ta='tmux a -t'
alias tk='tmux kill-session -t'

# completion
[ ! -d "${XDG_CACHE_HOME}/zsh" ] && mkdir -p "${XDG_CACHE_HOME}/zsh"
autoload -Uz compinit && compinit -d "${XDG_CACHE_HOME}/zsh/zcompdump"
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' special-dirs false
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:*:*:users' ignored-patterns '_*'
zstyle ':completion:*' rehash true

setopt COMPLETE_ALIASES
setopt COMPLETE_IN_WORD
setopt PATH_DIRS
unsetopt CASE_GLOB
setopt AUTO_CD
setopt NULL_GLOB

# auto-expand aliases inline
globalias () {
   zle _expand_alias
   zle expand-word
   zle self-insert
}
zle -N globalias
bindkey ' ' globalias
bindkey '^ ' magic-space            # control-space to bypass completion
bindkey -M isearch ' ' magic-space  # normal space during history searches

# history
[ ! -d "${XDG_DATA_HOME}/zsh" ] && mkdir -p "${XDG_DATA_HOME}/zsh"
export HISTFILE="${XDG_DATA_HOME}/zsh/history"
export HISTSIZE=1000000
export SAVEHIST="$HISTSIZE"
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

function df_basename () {
    dir=${1%${1##*[!/]}}
    dir=${dir##*/}
    printf %s "${dir:-/}"
}

function df_dirname () {
    dir=${1:-.}
    dir=${dir%%"${dir##*[!/]}"}
    [ "${dir##*/*}" ] && dir=.
    dir=${dir%/*}
    dir=${dir%%"${dir##*[!/]}"}
    printf %s "${dir:-/}"
}

function df_stripext () {
    printf %s "${1%.*}"
}

function df_getext () {
    printf %s "${1##*.}"
}

function vcut () {
    fp="$1"
    fn="$(df_basename "$fp")"
    fd="$(df_dirname "$fp")"
    fn_noext="$(df_stripext "$fn")"
    fe="$(df_getext "$fn")"
    ffmpeg -i "$fp" -ss "$2" -to "$3" -c copy "${fd}/${fn_noext}-cut-${2}-${3}.${fe}"
}

function ecount () {
    fd -tf --color=never | awk -F. 'NF > 1 {print tolower($NF)}' | sort | uniq -c | sort -n
}

function webp-to-jpg () {
    # need to implement a rm if success in vips_webpsave
    fd -tf -e webp --color=never -0 -x vips copy {} {.}.jpg
}
