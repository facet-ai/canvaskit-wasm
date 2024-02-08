# canvaskit-wasm

**IMPORTANT**: This is a public repository. Don't push anything sensitive.

This repository contains a custom build of [`canvaskit-wasm`](https://www.npmjs.com/package/canvaskit-wasm). It is based
on the basic canvaskit build with the following changes:

* Adds JPEG encoding support.

## Instructions

The package is built using the `build.sh` script. To build a new canvaskit bundle you can edit this script as needed and
run it. For example, you can change the `CANVASKIT_VERSION` variable to build a new version or change the compilation
flags to enable/disable features. After building, commit all changes and push.
