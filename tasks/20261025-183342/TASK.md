# Create config file for client and server and read this config

- STATUS: CLOSED
- PRIORITY: 100
- TAGS:

[x] - Use toml file format and toml-parser haskell library with the file format something like this

```toml
private-key-file = "./t2.key"
peer-public-key = "B64_PRIVATE_KEY"
prologue = "ppn/v1"
```


[x] - I need to parse the Main function arguments and create 2 modes

```shell
ppn keygen -o file.key
ppn run -m initiator/responder -i file.conf
```
