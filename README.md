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

References:
- https://noiseexplorer.com/patterns/KX/
- https://noiseprotocol.org/noise.html
- https://hackage.haskell.org/package/cacophony
