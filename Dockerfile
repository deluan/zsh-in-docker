FROM alpine:latest

COPY zsh-in-docker.sh /tmp
# RUN sh -c "$(wget -O- https://raw.githubusercontent.com/deluan/zsh-in-docker/master/zsh-in-docker.sh)" -- \
RUN sh -c "$(cat /tmp/zsh-in-docker.sh)" -- \
    -p "git" \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-history-substring-search \
    -p https://github.com/zsh-users/zsh-syntax-highlighting

ENTRYPOINT [ "/bin/zsh" ]
CMD ["-l"]
