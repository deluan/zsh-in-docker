source ./assert.sh
set -e

trap 'docker-compose stop -t 1' EXIT INT

test_suite() {
    image_name=$1
    echo
    echo "########## Testing in a $image_name container"
    echo

    set -x
    docker-compose rm --force --stop test-$image_name || true

    docker-compose up -d test-$image_name
    docker cp zsh-in-docker.sh zsh-in-docker_test-${image_name}_1:/tmp
    docker exec zsh-in-docker_test-${image_name}_1 sh /tmp/zsh-in-docker.sh \
        -t agnoster \
        -p git -p git-auto-fetch \
        -p https://github.com/zsh-users/zsh-autosuggestions \
        -p https://github.com/zsh-users/zsh-completions
    set +x

    echo
    VERSION=$(docker exec zsh-in-docker_test-${image_name}_1 zsh --version)
    ZSHRC=$(docker exec zsh-in-docker_test-${image_name}_1 cat /root/.zshrc)
    echo "########################################################################################"
    echo "$ZSHRC"
    echo "########################################################################################"
    echo "Test: zsh 5 was installed" && assert_contain "$VERSION" "zsh 5" "!"
    echo "Test: ~/.zshrc was generated" && assert_contain "$ZSHRC" 'ZSH="/root/.oh-my-zsh"' "!"
    echo "Test: theme was configured" && assert_contain "$ZSHRC" 'ZSH_THEME="agnoster"' "!"
    echo "Test: plugins were configured" && assert_contain "$ZSHRC" 'plugins=(git git-auto-fetch zsh-autosuggestions zsh-completions )' "!"

    echo
    echo "######### Success! All tests are passing for ${image_name}"

    docker-compose stop -t 1 test-$image_name
}

images=${*:-"alpine centos ubuntu debian amazonlinux"}

for image in $images; do
    test_suite $image
done
