set -g fish_native_prompt 1

set -g fish_autosuggestion_enabled 0
set fish_greeting

set -gx PATH $HOME/dev/tools/bin $HOME/usr/bin $HOME/.local/bin $HOME/.cache/.bun/bin /opt/homebrew/bin $PATH
set -gx EDITOR /usr/local/bin/e
set -gx PAGER /usr/local/bin/lz

# su=00:sg=00:ca=00 don't colorize setuid/gid or filecaps to avoid expensive syscalls
# or=40;31;01 broken symlinks are red
set -gx LS_COLORS 'su=00:sg=00:ca=00:or=40;31;01:'

set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_DATA_HOME "$HOME/.local/share"

set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK 1
set -gx HOMEBREW_NO_INSTALL_CLEANUP 1
set -gx HOMEBREW_NO_ANALYTICS 1

set -gx CARGO_NET_GIT_FETCH_WITH_CLI true

abbr --add e /usr/local/bin/e

abbr --add l /bin/ls
abbr --add ll /bin/ls -plAhG

abbr --add p   /usr/local/bin/play
abbr --add pd  $HOME/dev/play/target/debug/play
abbr --add mpv /Applications/mpv.app/Contents/MacOS/
abbr --add mp  /Applications/mpv.app/Contents/MacOS/mpv -vo null

abbr --add fd  fd --prune
abbr --add fdh fd --prune --no-ignore-vcs -H -E '.git/'
abbr --add rg  rg -S
abbr --add rgh rg --hidden -S -g '!.git'
abbr --add du  duf

# abbr --add p   procs

abbr --add syncthing syncthing serve --no-port-probing --no-browser --no-upgrade --gui-address='http://127.0.0.1:6969'
abbr --add wol "$HOME/usr/bin/wol" '7c:83:34:bd:05:c4'
abbr --add tu '/Applications/Tailscale.app/Contents/MacOS/Tailscale' up
abbr --add td '/Applications/Tailscale.app/Contents/MacOS/Tailscale' down

abbr --add gaa /opt/homebrew/bin/git add --all
abbr --add gcm /opt/homebrew/bin/git commit -m
abbr --add gd  /opt/homebrew/bin/git d
abbr --add gdd /opt/homebrew/bin/git diff --name-only --diff-filter=U
abbr --add gdc /opt/homebrew/bin/git dc
abbr --add gl  /opt/homebrew/bin/git l
abbr --add gp  /opt/homebrew/bin/git push -u
abbr --add grv /opt/homebrew/bin/git remote -v
abbr --add gs  /opt/homebrew/bin/git status -sb
abbr --add gss /opt/homebrew/bin/git status -sb -uall

function gr
    [ -n $argv[1] ] && /opt/homebrew/bin/git reset HEAD~$argv[1] || /opt/homebrew/bin/git reset
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
        --remote-components 'ejs:npm' \
        --js-runtimes bun:/opt/homebrew/bin/bun \
        -f 'ba' \
        --add-metadata \
        -o "%(title)s [%(id)s].%(ext)s" $argv
end

function mpdl
    $HOME/usr/py/.venv/bin/python -m yt_dlp --ignore-config --ignore-errors \
        --remote-components 'ejs:npm' \
        --js-runtimes bun:/opt/homebrew/bin/bun \
        -f 'ba' \
        --add-metadata \
        -o "%(playlist_title)s/%(playlist_index)02d - %(title)s [%(id)s].%(ext)s" $argv[1]
end

function vdl
    $HOME/usr/py/.venv/bin/python -m yt_dlp --ignore-config --ignore-errors \
        --remote-components 'ejs:npm' \
        --js-runtimes bun:/opt/homebrew/bin/bun \
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
set -gx PATH $HOME/.local/share/sentry-devenv/bin $PATH
# eval "$(direnv hook fish)"
denv hook fish | source

