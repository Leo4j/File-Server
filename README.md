# File-Server
A simple TCP file server that will serve files (located within the folder you specify) from 0.0.0.0

If not specified, Port will be set to `8080`, and PAth to `$pwd`

### Load in memory
```
iex(new-object net.webclient).downloadstring('https://raw.githubusercontent.com/Leo4j/File-Server/main/File-Server.ps1')
```

### Run
```
File-Server -Port 8080 -Path "c:\Users\Public\Documents"
```
