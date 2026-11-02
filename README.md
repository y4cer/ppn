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

## Tests

Hspec runs three QuickCheck properties (session, framing, TOML) and one regression
test for truncated authentication tags. Tests generate their own keys and need no
`noise-repl` or `test-files/` fixtures.

```sh
stack test
# Replay generated inputs from a reported seed:
stack test --test-arguments='--seed=12345 +RTS -N2 -RTS'
```

---

References:
- https://noiseexplorer.com/patterns/KX/
- https://noiseprotocol.org/noise.html
- https://hackage.haskell.org/package/cacophony

---

Copyright 2026 y4cer
