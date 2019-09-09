#!/bin/sh
set -e

THEME=powerlevel10k/powerlevel10k
PLUGINS=""

while getopts ":t:p:" opt; do
    case ${opt} in
        t)
            THEME=$OPTARG
            ;;
        p)
            PLUGINS="${PLUGINS}$OPTARG "
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
        echo $ID
    )
}

install_dependencies() {
    DIST=`check_dist`
    echo "###### Installing dependencies for $DIST"
    case $DIST in
        alpine)
            apk add --update --no-cache git curl zsh
        ;;
        centos)
            yum update
            yum install -y git curl
            curl http://mirror.ghettoforge.org/distributions/gf/el/7/plus/x86_64/zsh-5.1-1.gf.el7.x86_64.rpm > zsh-5.1-1.gf.el7.x86_64.rpm
            rpm -i zsh-5.1-1.gf.el7.x86_64.rpm
        ;;
        *)
            apt-get update
            apt-get -y install git curl zsh locales locales-all
            locale-gen en_US.UTF-8
    esac
}

zshrc_template() {
    _HOME=$1; 
    _THEME=$2; shift; shift
    _PLUGINS=$*;

    cat <<EOM
export LANG='en_US.UTF-8'
export LANGUAGE='en_US:en'
export LC_ALL='en_US.UTF-8'
export TERM=xterm

##### Zsh/Oh-my-Zsh Configuration
export ZSH="$_HOME/.oh-my-zsh"

ZSH_THEME="${_THEME}"
plugins=($_PLUGINS)

source \$ZSH/oh-my-zsh.sh

bindkey "\$terminfo[kcuu1]" history-substring-search-up
bindkey "\$terminfo[kcud1]" history-substring-search-down
EOM
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

install_dependencies

cd /tmp

if [ ! -d $HOME/.oh-my-zsh ]; then
    trap 'rm -f /tmp/install.sh' EXIT
    curl -Lo install.sh https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh
    sh install.sh --unattended
fi

set +x
plugin_list=""
for plugin in $PLUGINS; do
    if [ "`echo $plugin | grep -E '^http.*'`" != "" ]; then
        plugin_name=`basename $plugin`
        git clone $plugin $HOME/.oh-my-zsh/custom/plugins/$plugin_name
    else
        plugin_name=$plugin
    fi
    plugin_list="${plugin_list}$plugin_name "
done

zshrc_template "$HOME" "$THEME" "$plugin_list" > $HOME/.zshrc

if [ "$THEME" == "powerlevel10k/powerlevel10k" ]; then
    git clone https://github.com/romkatv/powerlevel10k $HOME/.oh-my-zsh/custom/themes/powerlevel10k
    powerline10k_config >> $HOME/.zshrc
fi
