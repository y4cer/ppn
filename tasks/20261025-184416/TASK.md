# Create VPN client and server

- STATUS: OPEN
- PRIORITY: 1
- TAGS: project

In this project we set the following milestones:

[ ] -  Working client-server communication using KX variant on the single machine without sockets
[ ] -  Working client-server communication using KX variant on the single machine using noise-repl by sending to the separate process
[ ] -  Make it configurable and easier for testing. Write code so configuration
    files can be read and generated. Incorporate noise-repl in the testing process, so the protocol sends 
[ ] -  Network core: spawn separate single-thread proccess for communication for both client and server
    - somehow implement state machine to deal with packet deduplication and attacker manipulations
[ ] - Network advanced: create separate network interface, make configurations,
    so the traffic goes into this interface
