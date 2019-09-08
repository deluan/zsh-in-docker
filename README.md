# Oh My Zsh Installer for Docker

This is a script to automate [Oh My Zsh](https://ohmyz.sh/) installation in development containers.
Works with any images based on Alpine, Ubuntu, Debian or CentOS.

The goal is to simplify installing zsh in a Docker image for use with [VSCode's Remote Conteiners
extension](https://code.visualstudio.com/docs/remote/containers)

## Usage

Add the following lines in your Dockerfile:

```Dockerfile
# This line is mandatory
RUN cd /tmp && wget https://raw.githubusercontent.com/deluan/zsh-in-docker/master/zsh-in-docker.sh
# This line is customizable (see examples bellow)
RUN sh /tmp/zsh-in-docker.sh [plugins] [external plugins]
```

Where:

- `plugins` is a string containing the bundled plugins that you want to activate. Ex: `"git ssh-agent"`
- `external plugins` is a list of git repos containing repos of plugins that you want to add

Examples:

```Dockerfile
# No plugins installed
RUN sh /tmp/zsh-in-docker.sh
```

```Dockerfile
# Install two bundled plugins
RUN sh /tmp/zsh-in-docker.sh "git ssh-agent"
```

```Dockerfile
# Install two bundled plugins + two externals
RUN sh /tmp/zsh-in-docker.sh "git ssh-agent" \
    https://github.com/zsh-users/zsh-autosuggestions \
    https://github.com/zsh-users/zsh-completions
```

```Dockerfile
# Only installs an external plugin
RUN sh /tmp/zsh-in-docker.sh "" https://github.com/zsh-users/zsh-completions
```

## Notes

As a side-effect, this script also installs `git` and `curl` in your image, if they are not available
