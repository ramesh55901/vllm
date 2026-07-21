#!/bin/bash
# Build vLLM Rust artifacts and install them into the vllm package.
# Usage: ./build_rust.sh [--debug]

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "Using system Rust toolchain"

which rustc
which cargo

rustc --version
cargo --version

if [[ "${1:-}" == "--debug" ]]; then
    PROFILE_ARG="--debug"
else
    PROFILE_ARG="--release"
fi

python3 "$REPO_ROOT/tools/build_rust.py" "$PROFILE_ARG"