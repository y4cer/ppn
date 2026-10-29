# Complete handshake stubs

- STATUS: DONE
- PRIORITY: 100
- TAGS:

In Handshake.hs there are 4 function stubs that need to be completed

```haskell
finishClientHandshake ::
  ClientHandshake ->
  ByteString ->
  Either PpnError Session
finishClientHandshake = undefined

acceptFirstClientMessage ::
  PendingServerSession ->
  ByteString ->
  Either PpnError Session
acceptFirstClientMessage = undefined

encryptMessage ::
  Session ->
  ByteString ->
  Either PpnError (ByteString, Session)
encryptMessage = undefined

decryptMessage ::
  Session ->
  ByteString ->
  Either PpnError (ByteString, Session)
decryptMessage = undefined
```
