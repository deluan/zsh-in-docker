source ./assert.sh
set -e

trap 'docker-compose stop -t 1' EXIT INT

test_suite() {
    image_name=$1
    echo
    echo "########## Testing on $image_name container"
    echo

    set -x
    docker-compose rm --force --stop test-$image_name || true

    docker-compose up -d test-$image_name
    docker cp zsh-in-docker.sh zsh-in-docker_test-${image_name}_1:/tmp
    docker exec zsh-in-docker_test-${image_name}_1 sh /tmp/zsh-in-docker.sh "git git-auto-fetch" \
        https://github.com/zsh-users/zsh-autosuggestions \
        https://github.com/zsh-users/zsh-completions
    set +x

    echo
    VERSION=$(docker exec zsh-in-docker_test-${image_name}_1 zsh --version)
    echo "Test: zsh 5 was installed" && assert_contain "$VERSION" "zsh 5" "!"

    ZSHRC=$(docker exec zsh-in-docker_test-${image_name}_1 cat /root/.zshrc)
    echo "Test: ~/.zshrc was generated" && assert_contain "$ZSHRC" 'ZSH="/root/.oh-my-zsh"' "!"
    echo "Test: plugins were configured" && assert_contain "$ZSHRC" 'plugins=(git git-auto-fetch zsh-autosuggestions zsh-completions)' "!"

    echo
    echo "######### Success! All tests are passing for ${image_name}"

    docker-compose stop -t 1 test-$image_name
}

images=${*:-"alpine centos ubuntu debian"}

for image in $images; do
    test_suite $image
done
