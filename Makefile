PREFIX ?= $(HOME)/.local
BINDIR = $(PREFIX)/bin
COMPLETIONDIR = $(PREFIX)/completions
LIBDIR = $(PREFIX)/lib
BOTTLE = "$(shell ls *.gz)"
VERSION := "$(shell psychrometrics --version)"

.PHONY: bottle
bottle:
	swift run --configuration release --disable-sandbox builder bottle
	@echo "Run 'make upload-bottle', once you've updated the formula"

.PHONY: upload-bottle
upload-bottle:
	gh release upload "$(VERSION)" "$(BOTTLE)"

.PHONY: remove-bottle
remove-bottle:
	rm -rf "$(BOTTLE)"

.PHONY: build
build:
	swift run --configuration release --disable-sandbox builder build

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
