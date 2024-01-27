df_require () {
    command -v "$1" 2>&1 > /dev/null
}

sw () {
	mkdir /tmp/xdg
	XDG_RUNTIME_DIR=/tmp/xdg sway
}

alias c='clear'
alias ..='cd ..'
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
gr () {
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

df_basename () {
    dir=${1%${1##*[!/]}}
    dir=${dir##*/}
    printf %s "${dir:-/}"
}

df_dirname () {
    dir=${1:-.}
    dir=${dir%%"${dir##*[!/]}"}
    [ "${dir##*/*}" ] && dir=.
    dir=${dir%/*}
    dir=${dir%%"${dir##*[!/]}"}
    printf %s "${dir:-/}"
}

df_stripext () {
    printf %s "${1%.*}"
}

df_getext () {
    printf %s "${1##*.}"
}

vcut () {
    fp="$1"
    fn="$(df_basename "$fp")"
    fd="$(df_dirname "$fp")"
    fn_noext="$(df_stripext "$fn")"
    fe="$(df_getext "$fn")"
    ffmpeg -i "$fp" -ss "$2" -to "$3" -c copy "${fd}/${fn_noext}-cut-${2//:/}-${3//:/}.${fe}"
}

ecount () {
    fd -tf --color=never | awk -F. 'NF > 1 {print tolower($NF)}' | sort | uniq -c | sort -n
}

esize () {
    fd -e "$1" -0 | xargs -0 du -hc | awk 'END { print $1 }'
}

webp-to-jpg () {
    # need to implement a rm if success in vips_webpsave
    fd -tf -e webp --color=never -0 -x vips copy {} {.}.jpg
}

optimize-jpg () {
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

optimize-jpg-no-strip () {
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

optimize-png () {
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

gitroot () {
    cd "$(git rev-parse --show-toplevel)"
}

sshnew () {
    # $0 [keypair name] [optional comment]
    ssh-keygen -t ed25519 -a 100 -f "${HOME}/.ssh/${1}" -N '' -C "$2"
    chmod 400 -v "${HOME}/.ssh/${1}"
    chmod 444 -v "${HOME}/.ssh/${1}.pub"
}

mdl () {
    case "$1" in
        *playlist*) echo "Use mpdl for playlists."; return 1 ;;
    esac

    python3 -m yt_dlp --ignore-config \
        -f 'ba[ext=m4a]' \
        --add-metadata \
        -o "%(title)s [%(id)s].%(ext)s" "$1"
}

mpdl () {
    python3 -m yt_dlp --ignore-config --ignore-errors \
        -f 'ba[ext=m4a]' \
        --add-metadata \
        -o "%(playlist_title)s/%(playlist_index)02d - %(title)s [%(id)s].%(ext)s" "$1"
}

vdl () {
    python3 -m yt_dlp --ignore-config --ignore-errors \
        -f 'bestvideo[height<=720]+bestaudio/best[height<=720]' \
        --write-sub --sub-lang=en --sub-format=srt --convert-subs=srt \
        --add-metadata \
        --merge-output-format mp4 \
        -o "%(title)s [%(id)s].%(ext)s" "$1"
}

msdl () {
  IFS=$'\n' urls=($(python3 -m yt_dlp --ignore-config -f 'ba[ext=m4a]' -g "$1"))
  ffmpeg -ss $2 -to $3 -i "${urls[1]}" -map 0:a -c:a copy $4
}

vsdl () {
  IFS=$'\n' urls=($(python3 -m yt_dlp --ignore-config -g "$1"))
  ffmpeg -ss $2 -to $3 -i "${urls[0]}" -ss $2 -i "${urls[1]}" -map 0:v -map 1:a $4
}
