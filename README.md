# ppn

PPN is a secure client-server toy communication VPN written in Haskell based on
KX pattern of the Noise protocol framework.

The protocol itself is (in the Noise language):

```
KX:
    -> s
    ...
    -> e
    <- e, ee, se, s, es
```

Proposed modules:
- Client    - for establishing client specific communication
- Server    - same, but for the server side
- Handshake - wrappers for Noise library calls, handshake and session establishment
- Config    - configuration, i.e. the static and remote keys

## Build & Install

```sh
stack build
```

## How to run

```sh
stack build
stack run 
```

```sh
$ stack run -- --help
ppn - a secure client-server communication based on Noise KX protocol

Usage: ppn-exe COMMAND

  Generate keypair or run a ppn in client or server mode

Available options:
  -h,--help                Show this help text

Available commands:
  keygen                   Generate a staic key
  run                      Run a peer
```

## Tests

Hspec runs three QuickCheck properties (session, framing, TOML). Tests generate
their own keys and do not need configs.

```sh
stack test
```

---

References:
- https://noiseexplorer.com/patterns/KX/
- https://noiseprotocol.org/noise.html
- https://hackage.haskell.org/package/cacophony

---

Copyright 2026 y4cer
