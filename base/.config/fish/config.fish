set -g fish_autosuggestion_enabled 0
set fish_greeting
fish_config theme choose none

fish_add_path $HOME/usr/bin /opt/homebrew/bin $HOME/.cargo/bin

set -gx EDITOR $HOME/usr/bin/micro
set -gx PAGER less
set -gx LESS FSXR

# su=00:sg=00:ca=00 don't colorize setuid/gid or filecaps to avoid expensive syscalls
# or=40;31;01 broken symlinks are red
set -gx LS_COLORS 'su=00:sg=00:ca=00:or=40;31;01:'

set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx LESSHISTFILE "$XDG_DATA_HOME/less_history"

set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK 1
set -gx HOMEBREW_NO_INSTALL_CLEANUP 1
set -gx HOMEBREW_NO_ANALYTICS 1

set -gx CARGO_NET_GIT_FETCH_WITH_CLI true

abbr --add c clear
abbr --add e $EDITOR

abbr --add l /bin/ls
abbr --add ll /bin/ls -plAhG

abbr --add fd  fd --prune
abbr --add fdh fd --prune --no-ignore-vcs -H -E '.git/'
abbr --add rg  rg -S
abbr --add rgh rg --hidden -S -g '!.git'

abbr --add gaa git add --all
abbr --add gcm git commit -m
abbr --add gd  git diff
abbr --add gdc git diff --cached
abbr --add gl  git log
abbr --add gp  git push -u
abbr --add grv git remote -v
abbr --add gs  git status -sb -uall

function gr
    [ -n $argv[1] ] && git reset HEAD~$argv[1] || git reset
end

function gitroot
    cd "$(git rev-parse --show-toplevel)"
end

abbr --add tl   tmux -f "$XDG_CONFIG_HOME/tmux/tmux.conf" ls
abbr --add tn   tmux -f "$XDG_CONFIG_HOME/tmux/tmux.conf" new -s
abbr --add ta   tmux -f "$XDG_CONFIG_HOME/tmux/tmux.conf" a -t
abbr --add tk   tmux -f "$XDG_CONFIG_HOME/tmux/tmux.conf" kill-session -t

abbr --add mp mpv -vo null

function multicd
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
abbr --add dotdot --regex '^\.\.+$' --function multicd

function fish_prompt
    printf '%s@%s %s%s%s %s $ ' \
        $USER \
        $hostname \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal) \
        "$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
end

function fish_right_prompt
    fish_status_to_signal $status
end

function sw
    mkdir /tmp/xdg
    XDG_RUNTIME_DIR=/tmp/xdg sway
end

function sshnew
    ssh-keygen -t ed25519 -a 100 -f $HOME/.ssh/$argv[1] -N '' -C $argv[2]
    chmod 400 -v $HOME/.ssh/$argv[1]
    chmod 444 -v $HOME/.ssh/$argv[1].pub
end

function du
    du -skh .??* * | sort -rh
end

function vcut
    set fp $argv[1]
    set fn (path basename $fp)
    set fd (path dirname $fp)
    set fn_noext (path change-extension '' $fn)
    set fext (string split -r -m1 . $fn)[-1]
    set ss (string replace --all ':' '' $argv[2])
    set to (string replace --all ':' '' $argv[3])
    ffmpeg -ss $argv[2] -accurate_seek -i "$fp" -to $argv[3] -c copy -map 0 "$fd/$fn_noext-cut-$ss-$to.$fext"
end

function ecount
    fd --color=never -tf | awk -F. 'NF > 1 {print tolower($NF)}' | sort | uniq -c | sort -n
end

function esize
    fd --color=never -e $argv[1] -0 | xargs -0 du -hc | awk 'END { print $1 }'
end

function mdl
    switch $argv[1]
        case '*playlist*'
            echo "Use mpdl for playlists."
    end

    $HOME/usr/py/.venv/bin/python -m yt_dlp --ignore-config \
        -f 'ba[ext=m4a]' \
        --add-metadata \
        -o "%(title)s [%(id)s].%(ext)s" $argv[1]
end

function mpdl
    $HOME/usr/py/.venv/bin/python -m yt_dlp --ignore-config --ignore-errors \
        -f 'ba[ext=m4a]' \
        --add-metadata \
        -o "%(playlist_title)s/%(playlist_index)02d - %(title)s [%(id)s].%(ext)s" $argv[1]
end

function vdl
    $HOME/usr/py/.venv/bin/python -m yt_dlp --ignore-config --ignore-errors \
        -f 'bestvideo[height<=720]+bestaudio/best[height<=720]' \
        --write-sub --sub-lang=en --sub-format=srt --convert-subs=srt \
        --add-metadata \
        --merge-output-format mp4 \
        -o "%(title)s [%(id)s].%(ext)s" $argv[1]
end

function msdl
    set urls $(IFS=$'\n' $HOME/usr/py/.venv/bin/python -m yt_dlp --ignore-config -f 'ba[ext=m4a]' -g $argv[1])
    ffmpeg -ss $argv[2] -to $argv[3] -i $urls[1] -map 0:a -c:a copy $argv[4]
end

function vsdl
    set urls $(IFS=$'\n' $HOME/usr/py/.venv/bin/python -m yt_dlp --ignore-config -g $argv[1])
    ffmpeg -ss $argv[2] -to $argv[3] -i $urls[0] -ss $argv[2] -i $urls[1] -map 0:v -map 1:a $argv[4]
end

function optimize-jpg
    set tmp $(mktemp)
    fd -tf --color=never -0 \
        -e jpg -e jpeg \
        > $tmp
    set count $(awk -vRS='\0' 'END{print NR}' < $tmp)
    set nproc 8
    set n (math 1 + (count / nproc))
    # I think gnu parallel will not clobber output?
    xargs -0 -t -P$nproc -n$n \
        jpegoptim -m90 -s \
        < $tmp
    rm -f $tmp
end

function optimize-jpg-no-strip
    set tmp $(mktemp)
    fd -tf --color=never -0 \
        -e jpg -e jpeg \
        > $tmp
    set count $(awk -vRS='\0' 'END{print NR}' < $tmp)
    set nproc 8
    set n (math 1 + (count / nproc))
    xargs -0 -t -P$nproc -n$n \
        jpegoptim -m90 --strip-none \
        < $tmp
    rm -f $tmp
end

function optimize-png
    set tmp $(mktemp)
    fd -tf --color=never -0 \
        -e png \
        > $tmp
    set count $(awk -vRS='\0' 'END{print NR}' < $tmp)
    set nproc 8
    set n (math 1 + (count / nproc))
    xargs -0 -t -P$nproc -n$n \
        pngquant --skip-if-larger --quality=90 --strip --speed 1 --ext .png --force \
        < $tmp
    rm -f $tmp
end

function insta
    $HOME/usr/py/.venv/bin/python -m gallery_dl \
        -c ~/Sync/Staging/gallery-dl.conf \
        --no-check-certificate \
        -D . \
        $argv[1]
    # rm .mp4.json
end

function instam
    $HOME/usr/py/.venv/bin/python -m gallery_dl \
        -c ~/Sync/Staging/gallery-dl.conf \
        --no-check-certificate \
        --write-metadata -P=insta-meta \
        -D . \
        $argv[1]
    # rm .mp4.json
end

# work
fish_add_path $HOME/.local/share/sentry-devenv/bin
eval "$(direnv hook fish)"
