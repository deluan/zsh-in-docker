help: ## Show help information.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make <target> \
	\033[36m\033[0m\n\nTargets:\n"}/^[a-zA-Z_-]+:.*?##/ \
	{ printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2 }' \
	$(MAKEFILE_LIST)

test: ## Run tests on Alpine only
	./test.sh alpine
.PHONY: test

test-all: ## Run tests on all supported images
	./test.sh
.PHONY: test-all

release: ## Release a new version. Syntax: `make release V=X.X.X`
	@if [[ ! "${V}" =~ ^[0-9]+\.[0-9]+\.[0-9]+.*$$ ]]; then echo "Usage: make release V=X.X.X"; exit 1; fi
	@if [ -n "`git status -s`" ]; then echo "\n\nThere are pending changes. Please commit or stash first"; exit 1; fi
	make test
	git tag v${V}
	git push origin v${V}
.PHONY: release
