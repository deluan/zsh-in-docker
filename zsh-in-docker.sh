#!/bin/sh

#######################################################################################################
# MIT License (MIT)
# Copyright 2019 Deluan Quintao
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute,
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
# OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#######################################################################################################

set -e

THEME=default
PLUGINS=""
ZSHRC_APPEND=""
INSTALL_DEPENDENCIES=true

while getopts ":t:p:a:x" opt; do
    case ${opt} in
        t)  THEME=$OPTARG
            ;;
        p)  PLUGINS="${PLUGINS}$OPTARG "
            ;;
        a)  ZSHRC_APPEND="$ZSHRC_APPEND\n$OPTARG"
            ;;
        x)  INSTALL_DEPENDENCIES=false
            ;;
        \?)
            echo "Invalid option: $OPTARG" 1>&2
            ;;
        :)
            echo "Invalid option: $OPTARG requires an argument" 1>&2
            ;;
    esac
done
shift $((OPTIND -1))

echo
echo "Installing Oh-My-Zsh with:"
echo "  THEME   = $THEME"
echo "  PLUGINS = $PLUGINS"
echo

check_dist() {
    (
        . /etc/os-release
        echo "$ID"
    )
}

check_version() {
    (
        . /etc/os-release
        echo "$VERSION_ID"
    )
}

install_dependencies() {
    DIST=$(check_dist)
    VERSION=$(check_version)
    echo "###### Installing dependencies for $DIST"

    if [ "$(id -u)" = "0" ]; then
        Sudo=''
    elif which sudo; then
        if [[ ! -z "$SUDO_PASSWORD" ]]; then
            Sudo="echo $SUDO_PASSWORD | sudo -S "
        else
            Sudo="sudo"
        fi
    else
        echo "WARNING: 'sudo' command not found. Skipping the installation of dependencies. "
        echo "If this fails, you need to do one of these options:"
        echo "   1) Install 'sudo' before calling this script"
        echo "OR"
        echo "   2) Install the required dependencies: git curl zsh"
        return
    fi

    case $DIST in
        alpine)
            $Sudo apk add --update --no-cache git curl zsh
        ;;
        amzn)
            $Sudo yum update -y
            $Sudo yum install -y git zsh
            $Sudo yum install -y ncurses-compat-libs # this is required for AMZN Linux (ref: https://github.com/emqx/emqx/issues/2503)
        ;;
        rhel|fedora|rocky)
            $Sudo yum update -y
            $Sudo yum install -y git zsh
        ;;
        *)
            $Sudo apt-get update
            $Sudo apt-get -y install git curl zsh locales
            if [ "$VERSION" != "14.04" ]; then
                $Sudo apt-get -y install locales-all
            fi
            $Sudo locale-gen en_US.UTF-8
    esac
}

zshrc_template() {
    _HOME=$1;
    _THEME=$2; shift; shift
    _PLUGINS=$*;

    if [ "$_THEME" = "default" ]; then
        _THEME="powerlevel10k/powerlevel10k"
    fi

    cat <<EOM
export LANG='en_US.UTF-8'
export LANGUAGE='en_US:en'
export LC_ALL='en_US.UTF-8'
[ -z "$TERM" ] && export TERM=xterm

##### Zsh/Oh-my-Zsh Configuration
export ZSH="$_HOME/.oh-my-zsh"

ZSH_THEME="${_THEME}"
plugins=($_PLUGINS)

EOM
    printf "$ZSHRC_APPEND"
    printf "\nsource \$ZSH/oh-my-zsh.sh\n"
}

powerline10k_config() {
    cat <<EOM
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_to_last"
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(user dir vcs status)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
POWERLEVEL9K_STATUS_OK=false
POWERLEVEL9K_STATUS_CROSS=true
EOM
}

if [ "$INSTALL_DEPENDENCIES" = true ]; then
    install_dependencies
fi

cd /tmp

# Install On-My-Zsh
if [ ! -d "$HOME"/.oh-my-zsh ]; then
    sh -c "$(curl https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
fi

# Generate plugin list
plugin_list=""
for plugin in $PLUGINS; do
    if [ "$(echo "$plugin" | grep -E '^http.*')" != "" ]; then
        plugin_name=$(basename "$plugin")
        git clone "$plugin" "$HOME"/.oh-my-zsh/custom/plugins/"$plugin_name"
    else
        plugin_name=$plugin
    fi
    plugin_list="${plugin_list}$plugin_name "
done

# Handle themes
if [ "$(echo "$THEME" | grep -E '^http.*')" != "" ]; then
    theme_repo=$(basename "$THEME")
    THEME_DIR="$HOME/.oh-my-zsh/custom/themes/$theme_repo"
    git clone "$THEME" "$THEME_DIR"
    theme_name=$(cd "$THEME_DIR"; ls *.zsh-theme | head -1)
    theme_name="${theme_name%.zsh-theme}"
    THEME="$theme_repo/$theme_name"
fi

# Generate .zshrc
zshrc_template "$HOME" "$THEME" "$plugin_list" > "$HOME"/.zshrc

# Install powerlevel10k if no other theme was specified
if [ "$THEME" = "default" ]; then
    git clone --depth 1 https://github.com/romkatv/powerlevel10k "$HOME"/.oh-my-zsh/custom/themes/powerlevel10k
    powerline10k_config >> "$HOME"/.zshrc
fi
