# Oh My Zsh Installer for Docker

[![Build](https://img.shields.io/github/workflow/status/deluan/zsh-in-docker/CI?style=flat-square)](https://github.com/deluan/zsh-in-docker/actions)

This is a script to automate [Oh My Zsh](https://ohmyz.sh/) installation in development containers.
Works with any images based on Alpine, Ubuntu, Debian, CentOS or Amazon Linux.

The original goal was to simplify setting up `zsh` and Oh My Zsh in a Docker image for use with [VSCode's Remote Conteiners
extension](https://code.visualstudio.com/docs/remote/containers), but it can be used in any case you
need a simple way to install Oh My Zsh and its plugins in a Docker image

## Usage

One line installation: add the following line in your `Dockerfile`:

```Dockerfile
# Default powerline10k theme, no plugins installed
RUN sh -c "$(wget -O- https://raw.githubusercontent.com/deluan/zsh-in-docker/master/zsh-in-docker.sh)"
```

#### Optional arguments:

- `-t <theme>` - Selects the theme to be used. Options are available
  [here](https://github.com/robbyrussell/oh-my-zsh/wiki/Themes). By default the script installs
  and uses [Powerlevel10k](https://github.com/romkatv/powerlevel10k), one the
  "fastest and most awesome" themes for `zsh`. This is the recomended theme, as it is extremely fast
  for git info updates
- `-p <plugin>` - Specifies a plugin to be configured in the generated `.zshrc`. List of bundled
  Oh My Zsh plugins are available [here](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins).
  If `<plugin>` is a url, the script will try to install the plugin using `git clone`.
- `-a <line>` - You can add extra lines at the end of the generated `.zshrc` by passing one `-a` argument for
  each line you want to add. Ex: if you want to enable [case sensitive completion](https://stackoverflow.com/a/28021691):
  ```
  RUN sh -c "$(wget -O- https://raw.githubusercontent.com/deluan/zsh-in-docker/master/zsh-in-docker.sh)" -a 'CASE_SENSITIVE="true"'
  ```

#### Examples:

```Dockerfile
# Uses "robbyrussell" theme (original Oh My Zsh theme), with no plugins
RUN sh -c "$(wget -O- https://raw.githubusercontent.com/deluan/zsh-in-docker/master/zsh-in-docker.sh)" -- \
    -t robbyrussell
```

```Dockerfile
# Uses "git", "ssh-agent" and "history-substring-search" bundled plugins
RUN sh -c "$(wget -O- https://raw.githubusercontent.com/deluan/zsh-in-docker/master/zsh-in-docker.sh)" -- \
    -p git -p ssh-agent -p 'history-substring-search' \
    -a 'bindkey "\$terminfo[kcuu1]" history-substring-search-up' \
    -a 'bindkey "\$terminfo[kcud1]" history-substring-search-down'

```

```Dockerfile
# Uses "agnoster" theme, uses some bundled plugins and install some more from github
RUN sh -c "$(wget -O- https://raw.githubusercontent.com/deluan/zsh-in-docker/master/zsh-in-docker.sh)" -- \
    -t agnoster \
    -p git \
    -p ssh-agent \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions
```

## Notes

- The examples above use `wget`, but if you prefer `curl`, just replace `wget -O-` with `curl`
- This scripts requires `git` and `curl` to work properly. If your `Dockerfile` uses `root` as the
  main user, it should be fine, as the script will install them automatically. If you are using a
  non-root user, make sure to install the `sudo` package _OR_ to install `git` and `curl` packages
  _before_ calling this script
- By default this script install the `powerlevel10k` theme, as it is one of the fastest and most
  customizable themes available for zsh. If you want the default Oh My Zsh theme, uses the option
  `-t robbyrussell`
  
## Liked it?

If you like this script, feel free to thank me with a [coffee (or beer ;) )](https://ko-fi.com/K3K21VMDV)
