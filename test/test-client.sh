#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

stack build
PPN="$(stack path --local-install-root)/bin/ppn-exe"

CLIENT_PUBLIC="$(
  sed -n 's/^peer-public-key = "\(.*\)"/\1/p' test-files/t2.toml
)"

noise-repl \
  --name Noise_KX_25519_AESGCM_SHA256 \
  --role responder \
  --prologue 'ppn/v1' \
  --format plain \
  --local-static "$(tr -d '\r\n' < test-files/t2.key)" \
  --remote-static "$CLIENT_PUBLIC" \
  --pipe "exec \"$PPN\" run -m initiator -i test-files/t1.toml"
