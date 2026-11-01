#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

stack build
PPN="$(stack path --local-install-root)/bin/ppn-exe"

exec noise-repl \
  --name Noise_KX_25519_AESGCM_SHA256 \
  --role initiator \
  --prologue 'ppn/v1' \
  --format plain \
  --local-static "$(tr -d '\r\n' < test-files/t1.key)" \
  --pipe "exec \"$PPN\" run -m responder -i test-files/t2.toml"
