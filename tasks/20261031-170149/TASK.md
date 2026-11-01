# Implement client with the Transport

- STATUS: CLOSED
- PRIORITY: 100
- TAGS:

The client in `src/Client.h` now has the `runClient` function, which itself is
actually both client and the server. We need to implement the transport for the 
messages first, then use this transport for communication between client and the server.

Transport in: 20261031-170348
