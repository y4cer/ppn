# Implement Transport for communication

- STATUS: CLOSED
- PRIORITY: 100
- TAGS:

The client and server now have no communiction layer, except for the
inside-process one. Need to implement the transport, which will be the wrapper
for either stdin/stdout or the socket layer. 

Start with the stdin/stdout transport, only then the sockets.
