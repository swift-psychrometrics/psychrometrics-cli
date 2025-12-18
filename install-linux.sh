#!/usr/bin/env bash

# Builds the psychrometric-cli in a docker container, then
# copies built tool to DEST.

DEST="$HOME/.local/bin"

build() {
	podman run -it --rm \
		--volume "$PWD:/src" \
		--workdir /src \
		--env "SWIFT_BACKTRACE=enable=no" \
		docker.io/swift:latest \
		swift build --configuration release \
		-Xswiftc -cross-module-optimization \
		--static-swift-stdlib
}

###### MAIN #####

while [[ $# -gt 0 ]]; do
	if [[ $1 == "-d" ]] || [[ $1 == "--destination" ]]; then
		DEST="$1"
	fi
	shift
done

mkdir -p "$DEST" &>/dev/null
build
cp .build/release/psychrometrics "$DEST"
