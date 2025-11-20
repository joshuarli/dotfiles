set -g fish_autosuggestion_enabled 0
set fish_greeting
fish_config theme choose None

fish_add_path $HOME/usr/bin /opt/homebrew/bin

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

abbr --add e GOGC=off $EDITOR

abbr --add l /bin/ls
abbr --add ll /bin/ls -plAhG

abbr --add mpv /Applications/mpv.app/Contents/MacOS/mpv
abbr --add mp  /Applications/mpv.app/Contents/MacOS/mpv -vo null

abbr --add fd  fd --prune
abbr --add fdh fd --prune --no-ignore-vcs -H -E '.git/'
abbr --add rg  rg -S
abbr --add rgh rg --hidden -S -g '!.git'
abbr --add du  duf

abbr --add syncthing syncthing serve --no-port-probing --no-browser --no-upgrade --gui-address='http://127.0.0.1:6969'

# apple's /usr/bin/git is way smaller and faster than homebrew's
abbr --add gaa /usr/bin/git add --all
abbr --add gcm /usr/bin/git commit -m
abbr --add gd  /usr/bin/git diff
abbr --add gdc /usr/bin/git diff --cached
abbr --add gl  /usr/bin/git log
abbr --add gp  /usr/bin/git push -u
abbr --add grv /usr/bin/git remote -v
abbr --add gs  /usr/bin/git status -sb -uall
abbr --add gss /usr/bin/git diff --name-only --diff-filter=U

function gr
    [ -n $argv[1] ] && /usr/bin/git reset HEAD~$argv[1] || /usr/bin/git reset
end

function gitroot
    cd "$(git rev-parse --show-toplevel)"
end

abbr --add tl tmux -f "$XDG_CONFIG_HOME/tmux/tmux.conf" ls
abbr --add tn tmux -f "$XDG_CONFIG_HOME/tmux/tmux.conf" new -s
abbr --add ta tmux -f "$XDG_CONFIG_HOME/tmux/tmux.conf" a -t
abbr --add tk tmux -f "$XDG_CONFIG_HOME/tmux/tmux.conf" kill-session -t

function multicd
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
abbr --add dotdot --regex '^\.\.+$' --function multicd

function fish_prompt
    printf '%s@%s %s%s%s %s $ ' \
        $USER \
        $hostname \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal) \
        "$(/usr/bin/git rev-parse --abbrev-ref HEAD 2>/dev/null)"
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

function ecount
    fd --color=never -tf | awk -F. 'NF > 1 {print tolower($NF)}' | sort | uniq -c | sort -n
end

function esize
    fd --color=never -e $argv[1] -0 | xargs -0 /usr/bin/du -hc | awk 'END { print $1 }'
end

function mdl
    switch $argv[1]
        case '*playlist*'
            echo "Use mpdl for playlists."
    end

    $HOME/usr/py/.venv/bin/python -m yt_dlp --ignore-config \
        --remote-components 'ejs:github' \
        -f 'ba' \
        --add-metadata \
        -o "%(title)s [%(id)s].%(ext)s" $argv
end

function mpdl
    $HOME/usr/py/.venv/bin/python -m yt_dlp --ignore-config --ignore-errors \
        --remote-components 'ejs:github' \
        -f 'ba' \
        --add-metadata \
        -o "%(playlist_title)s/%(playlist_index)02d - %(title)s [%(id)s].%(ext)s" $argv[1]
end

function vdl
    $HOME/usr/py/.venv/bin/python -m yt_dlp --ignore-config --ignore-errors \
        --remote-components 'ejs:github' \
        -f 'bestvideo[height<=1080]+bestaudio/best[height<=1080]' \
        --write-sub --sub-lang=en --sub-format=srt --convert-subs=srt \
        --add-metadata \
        --merge-output-format mp4 \
        -o "%(title)s [%(id)s].%(ext)s" $argv
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

# work
fish_add_path $HOME/.local/share/sentry-devenv/bin
eval "$(direnv hook fish)"

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/josh/.lmstudio/bin
# End of LM Studio CLI section

