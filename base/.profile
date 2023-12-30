export EDITOR='micro'

# glibc localtime() will make less syscalls
export TZ=':/etc/localtime'

export PAGER='less'
export LESS='FSXR'

# su=00:sg=00:ca=00 don't colorize setuid/gid or filecaps to avoid expensive syscalls
# or=40;31;01 broken symlinks are red
export LS_COLORS='su=00:sg=00:ca=00:or=40;31;01:'

# xdg
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export LESSHISTFILE="${XDG_DATA_HOME}/less_history"

export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_ANALYTICS=1

export ENV="${HOME}/.kshrc"
export PATH="${HOME}/usr/bin:${PATH}"
