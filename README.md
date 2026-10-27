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

---

References:
- https://noiseexplorer.com/patterns/KX/
- https://noiseprotocol.org/noise.html
- https://hackage.haskell.org/package/cacophony

---

Copyright 2026 y4cer
