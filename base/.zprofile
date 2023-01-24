export PATH="${HOME}/bin:${HOME}/bin/misc:${HOME}/.cargo/bin:${HOME}/.local/bin:${PATH}"
export EDITOR=micro

# glibc localtime() will make less syscalls
export TZ=:/etc/localtime

export PAGER=less
export LESS=FSXR

export PROMPT='%n@%M %1d $ '

# su=00:sg=00:ca=00 don't colorize setuid/gid or filecaps to avoid expensive syscalls
# or=40;31;01 broken symlinks are red
export LS_COLORS='su=00:sg=00:ca=00:or=40;31;01:'

# xdg
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export ANDROID_SDK_HOME="${XDG_CONFIG_HOME}/android"
export LESSHISTFILE="${XDG_DATA_HOME}/less_history"

