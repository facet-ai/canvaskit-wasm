#!/usr/bin/env bash

set -euxo pipefail

CANVASKIT_VERSION=0.38.0

repo_root=$(git rev-parse --show-toplevel)

# Download canvaskit
canvaskit_tag="canvaskit/$CANVASKIT_VERSION"
if [ ! -d skia ]; then
  # Clone the repo if it doesn't exist
  git clone --depth 1 --branch "$canvaskit_tag" https://github.com/google/skia.git
else
  # Checkout the tag if the repo was already cloned
  cd skia
  git fetch origin +refs/tags/"$canvaskit_tag":refs/tags/"$canvaskit_tag"
  git checkout "$canvaskit_tag"
  git reset --hard "$canvaskit_tag"
  cd -
fi

# Install dependencies
cd skia
tools/git-sync-deps
bin/fetch-ninja

# Compile canvaskit
cd modules/canvaskit
./compile.sh release \
  no_skottie \
  no_sksl_trace \
  no_alias_font \
  no_effects_deserialization \
  no_encode_webp \
  legacy_draw_vertices \
  no_embedded_font

# Write npm package files
cd "$repo_root"
rm -rf bin
mkdir bin
cp skia/out/canvaskit_wasm/canvaskit.js   bin
cp skia/out/canvaskit_wasm/canvaskit.wasm bin
cp -r skia/modules/canvaskit/npm_build/types .
# Copy the package.json leaving only the exports for the basic canvaskit build
jq < skia/modules/canvaskit/npm_build/package.json >package.json \
  '.exports |= {".", "./bin/canvaskit", "./bin/canvaskit.js", "./bin/canvaskit.wasm"}'
