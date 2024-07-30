# Oh My Zsh Installer for Docker

[![Last Release](https://img.shields.io/github/v/release/deluan/zsh-in-docker?label=latest&style=flat-square)](https://github.com/deluan/zsh-in-docker/releases/latest)
[![Build](https://img.shields.io/github/actions/workflow/status/deluan/zsh-in-docker/test.yml?branch=master&style=flat-square)](https://github.com/deluan/zsh-in-docker/actions)
[![Downloads](https://img.shields.io/github/downloads/deluan/zsh-in-docker/total?style=flat-square)](https://github.com/deluan/zsh-in-docker/releases)


This is a script to automate [Oh My Zsh](https://ohmyz.sh/) installation in development containers.
Works with any image based on Alpine, Ubuntu, Debian, Amazon Linux, CentOS 7, RockyLinux 8,9 and Fedora.

The original goal was to simplify setting up `zsh` and Oh My Zsh in a Docker image for use with [VSCode's Remote Containers
extension](https://code.visualstudio.com/docs/remote/containers), but it can be used whenever you
need a simple way to install Oh My Zsh and its plugins in a Docker image

## Usage

One line installation: add the following line in your `Dockerfile`:

```Dockerfile
# Default powerline10k theme, no plugins installed
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)"
```

#### Optional arguments:

- `-t <theme>` - Selects the theme to be used. Options are available
  [here](https://github.com/robbyrussell/oh-my-zsh/wiki/Themes). By default the script installs
  and uses [Powerlevel10k](https://github.com/romkatv/powerlevel10k), one of the
  "fastest and most awesome" themes for `zsh`. This is my recommended theme. If `<theme>` is a url, the script will try to install the theme using `git clone`.
- `-p <plugin>` - Specifies a plugin to be configured in the generated `.zshrc`. List of bundled
  Oh My Zsh plugins are available [here](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins).
  If `<plugin>` is a url, the script will try to install the plugin using `git clone`.
- `-a <line>` - You can add extra lines at the end of the generated `.zshrc` (but before loading oh-my-zsh) by 
  passing one `-a` argument for each line you want to add. This is useful to customize plugins or themes. 
  For example, if you want to enable [case sensitive completion](https://stackoverflow.com/a/28021691):

  ```Dockerfile
  RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" -- \
  -a 'CASE_SENSITIVE="true"'
  ```
- `-u <username>` - You can install zsh in a specified user's directory, for example if you want zsh to be installed but the user not to have access to privleges that the root user has.
- `-x` - Skip installation of dependencies: `zsh`, `git`, `curl`. If you are having issues with the script failing to
  install these dependencies due to sudo permissions, you can install them yourself in a prior step, and use this flag
  to make the script skip their installation


#### Examples:

```Dockerfile
# Uses "robbyrussell" theme (original Oh My Zsh theme), with no plugins
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" -- \
    -t robbyrussell
```

```Dockerfile
# Same command as above, but installs zsh for specified user: dockeruser
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" -- \
    -t robbyrussell \
    -u dockeruser
```

```Dockerfile
# Uses "git", "ssh-agent" and "history-substring-search" bundled plugins
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" -- \
    -p git -p ssh-agent -p 'history-substring-search' \
    -a 'bindkey "\$terminfo[kcuu1]" history-substring-search-up' \
    -a 'bindkey "\$terminfo[kcud1]" history-substring-search-down'

```

```Dockerfile
# Uses "Spaceship" theme with some customization. Uses some bundled plugins and installs some more from github
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" -- \
    -t https://github.com/denysdovhan/spaceship-prompt \
    -a 'SPACESHIP_PROMPT_ADD_NEWLINE="false"' \
    -a 'SPACESHIP_PROMPT_SEPARATE_LINE="false"' \
    -p git \
    -p ssh-agent \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions
```

## Notes

- The examples above use `wget`, but if you prefer `curl`, just replace `wget -O-` with `curl -L`
- This scripts requires `git` and `curl` to work properly. If your `Dockerfile` uses `root` as the
  main user, it should be fine, as the script will install them automatically. If you are using a
  non-root user, make sure to install the `sudo` package _OR_ to install `git` and `curl` packages
  _before_ calling this script. In case `sudo` access is an issue and you already have `zsh`, `git` 
  and `curl`, you can use the option `-x` to skip the installations.
- By default this script will install the `powerlevel10k` theme, as it is one of the fastest and most
  customizable themes available for zsh. If you want the default Oh My Zsh theme, use the option
  `-t robbyrussell`
  
## Liked it?

If you like this script, feel free to thank me with a coffee (or a beer :wink:):

[![ko-fi](https://www.ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/K3K21VMDV)
