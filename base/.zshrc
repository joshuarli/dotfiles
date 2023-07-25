function df_require () {
    command -v "$1" 2>&1 > /dev/null
}

alias sway='XDG_RUNTIME_DIR=/tmp/xdg sway'

alias c='clear'
alias ..='cd ..'
alias ls='ls -F --color=always -v'
alias l='ls -p'
alias ll='ls -plAhG'
alias e="$EDITOR"

alias fd="fd --prune"
# fd: find hidden files, excluding .git/ but including gitignored files
# By the way, smart case is the default here which is quite nice.
alias fdh="fd --no-ignore-vcs -H -E '.git/'"

# rgh: grep through hidden files, excluding .git/ but including gitignored files
# (rg's default behavior is to ignore vcs ignore)
# AFAIK neither posix grep, gnu grep, nor git grep scratch this itch quite as elegantly as ripgrep does
# NOTE: add -l to list filenames only then | xargs $EDITOR
alias rg="rg -S"
alias rgh="rg --hidden -S -g '!.git'"

# see also ~/.config/git/config
alias gaa='git add --all'
alias gcm='git commit -m'
alias gd='git d'
alias gdc='git dc'
alias gl='git l'
alias gp='git push -u'
function gr () {
    [ -n "$1" ] && git reset HEAD~"$1" || git reset
}
alias grv='git remote -v'
alias gs='git status -sb -uall'

alias tmux="tmux -f ${XDG_CONFIG_HOME}/tmux/tmux.conf"
alias tl='tmux ls'
alias tn='tmux new -s'
alias ta='tmux a -t'
alias tk='tmux kill-session -t'

alias mp='mpv -vo null'

alias du='du -skh .??* * | sort -rh'
if df_require dua; then
    alias dua='dua i'
fi

function pathprepend () {
    for DIR in "$@"; do
        if [ ! -d "$DIR" ]; then
            # warn "pathprepend: ${DIR} does not exist"
            continue
        fi
        # not a completely correct test here, but good enough
        # (won't be correct if PATH is empty or DIR is the last entry in path)
        if [ ${PATH#*"${DIR}:"} != "$PATH" ]; then
            # warn "pathprepend: ${DIR} already in PATH; skipping"
            continue
        fi
        PATH="${DIR}${PATH:+":$PATH"}"
    done
}

export GOPATH="${XDG_DATA_HOME}/go"
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"
export CARGO_HOME="${XDG_DATA_HOME}/cargo"

pathprepend             \
    ${HOME}/bin         \
    ${HOME}/bin/misc    \
    ${HOME}/.local/bin  \
    "${GOPATH}/bin"     \
    "${CARGO_HOME}/bin"

export PATH="$PATH"

if df_require brew; then
    export HOMEBREW_NO_AUTO_UPDATE=1
    export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1
    export HOMEBREW_NO_INSTALL_CLEANUP=1
    export HOMEBREW_NO_ANALYTICS=1
fi

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

bindkey -e
# look in cat to see what comes up
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

calc () {
    bindkey ' ' self-insert
    autoload -Uz zcalc && zcalc
    bindkey ' ' globalias
}
alias bc=calc

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

function esize () {
    fd -e "$1" -0 | xargs -0 du -hc | awk 'END { print $1 }'
}

function webp-to-jpg () {
    # need to implement a rm if success in vips_webpsave
    fd -tf -e webp --color=never -0 -x vips copy {} {.}.jpg
}

function optimize-jpg () {
    tmp=$(mktemp)
    fd -tf --color=never -0 \
        -e jpg -e jpeg \
        > $tmp
    count=$(awk -vRS='\0' 'END{print NR}' < $tmp)
    nproc=8
    # I think gnu parallel will not clobber output?
    xargs -0 -t -P$nproc -n$(( 1 + (count / nproc) )) \
        jpegoptim -m90 -s \
        < $tmp
    rm -f $tmp
}

function optimize-jpg-no-strip () {
    tmp=$(mktemp)
    fd -tf --color=never -0 \
        -e jpg -e jpeg \
        > $tmp
    count=$(awk -vRS='\0' 'END{print NR}' < $tmp)
    nproc=8
    xargs -0 -t -P$nproc -n$(( 1 + (count / nproc) )) \
        jpegoptim -m90 --strip-none \
        < $tmp
    rm -f $tmp
}

function optimize-png () {
    tmp=$(mktemp)
    fd -tf --color=never -0 \
        -e png \
        > $tmp
    count=$(awk -vRS='\0' 'END{print NR}' < $tmp)
    nproc=8
    xargs -0 -t -P$nproc -n$(( 1 + (count / nproc) )) \
        pngquant --skip-if-larger --quality=90 --strip --speed 1 --ext .png --force \
        < $tmp
    rm -f $tmp
}

function gitroot () {
    cd "$(git rev-parse --show-toplevel)"
}

function sshnew () {
    # $0 [keypair name] [optional comment]
    ssh-keygen -t ed25519 -a 100 -f "${HOME}/.ssh/${1}" -N '' -C "$2"
    chmod 400 -v "${HOME}/.ssh/${1}"
    chmod 444 -v "${HOME}/.ssh/${1}.pub"
}

function mdl () {
    case "$1" in
        *playlist*) echo "Use mpdl for playlists."; return 1 ;;
    esac

    python3 -m yt_dlp --ignore-config --ignore-errors \
        -x --audio-format best \
        --postprocessor-args '-c:a libopus -b:a 96K' \
        --add-metadata \
        -o "%(title)s [%(id)s].%(ext)s" "$1"
}

function mpdl () {
    python3 -m yt_dlp --ignore-config --ignore-errors \
        -x --audio-format best \
        --postprocessor-args '-c:a libopus -b:a 96K' \
        --add-metadata \
        -o "%(playlist_title)s/%(playlist_index)02d - %(title)s [%(id)s].%(ext)s" "$1"
}

function vdl () {
    python3 -m yt_dlp --ignore-config --ignore-errors \
        -f 'bestvideo[height<=720]+bestaudio/best[height<=720]' \
        --write-sub --sub-lang=en --sub-format=srt --convert-subs=srt \
        --add-metadata \
        --merge-output-format mkv \
        -o "%(title)s [%(id)s].%(ext)s" "$1"
}

[[ -f "${XDG_CONFIG_HOME}/work" ]] && source "${XDG_CONFIG_HOME}/work"
