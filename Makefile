PREFIX ?= $(HOME)/.local
BINDIR = $(PREFIX)/bin
COMPLETIONDIR = $(PREFIX)/completions
LIBDIR = $(PREFIX)/lib
BOTTLE = "$(shell ls *.gz)"
VERSION := "$(shell psychrometrics --version)"
DOCKER_TAG := latest

.PHONY: bottle
bottle: set-version
	swift run --configuration release --disable-sandbox builder bottle
	@echo "Run 'make upload-bottle', once you've updated the formula"

.PHONY: upload-bottle
upload-bottle:
	gh release upload "$(VERSION)" "$(BOTTLE)"

.PHONY: remove-bottle
remove-bottle:
	rm -rf "$(BOTTLE)"

.PHONY: set-version
set-version:
	swift package --disable-sandbox \
		--allow-writing-to-package-directory \
		update-version \
		psychrometrics-cli

.PHONY: build
build: clean set-version
	swift build --configuration release

.PHONY: build-docker
build-docker: clean
	docker build -t "m-housh/psychrometrics:$(DOCKER_TAG)" "$(PWD)"

.PHONY: install
install: build
	install -d "$(BINDIR)" "$(LIBDIR)"
	install .build/release/psychrometrics "$(BINDIR)"

.PHONY: uninstall
uninstall:
	rm "$(BINDIR)/psychrometrics"
	rm "$(COMPLETIONDIR)/_psychrometrics"

.PHONY: clean
clean:
	rm -rf .build

.PHONY: run-publish-workflow
run-publish-workflow:
	gh workflow run publish.yml

.PHONY: test-linux
test-linux:
		docker run \
			--rm \
			-v "$(PWD):$(PWD)" \
			-w "$(PWD)" \
			swift:5.8 \
			swift test

.PHONY: test-swift
test-swift:
	swift test \
		--enable-test-discovery \
		--parallel
