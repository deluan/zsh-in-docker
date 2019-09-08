FROM alpine:latest

COPY zsh-in-docker.sh /tmp
RUN sh /tmp/zsh-in-docker.sh \
    https://github.com/zsh-users/zsh-autosuggestions \
    https://github.com/zsh-users/zsh-completions \
    https://github.com/zsh-users/zsh-history-substring-search \
    https://github.com/zsh-users/zsh-syntax-highlighting

ENTRYPOINT [ "/bin/zsh" ]
CMD ["-l"]
