#!/usr/bin/env bash

set -euo pipefail

# Git ref of the skia repo for which to build canvaskit
# We use git refs instead of tags because not all releases are tagged
SKIA_REF=a004a27085d7dcc4efc3766c9abe92df03654c7c # 0.39.1

repo_root=$(git rev-parse --show-toplevel)

# Create an empty skia repo if it doesn't exist
if [ ! -d skia ]; then
  mkdir skia
  cd skia
  git init
  git remote add origin https://github.com/google/skia.git
  cd -
fi

# Fetch the git ref
cd skia
git fetch --depth 1 origin "$SKIA_REF"
git reset --hard "$SKIA_REF"
cd -

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
