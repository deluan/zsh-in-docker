FROM alpine:latest

# RUN cd /tmp && wget https://raw.githubusercontent.com/deluan/zsh-in-docker/master/zsh-in-docker.sh
COPY zsh-in-docker.sh /tmp
RUN sh /tmp/zsh-in-docker.sh "git" \
    https://github.com/zsh-users/zsh-autosuggestions \
    https://github.com/zsh-users/zsh-completions \
    https://github.com/zsh-users/zsh-history-substring-search \
    https://github.com/zsh-users/zsh-syntax-highlighting

ENTRYPOINT [ "/bin/zsh" ]
CMD ["-l"]
