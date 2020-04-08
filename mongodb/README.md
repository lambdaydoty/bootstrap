# MongoDB

## Features

* (DB) Keyfile Authentication
* (DB) Replica Set
* (deployment) Makefile
* (deployment) Docker


## Usage

### Keyfile
```bash
make keygen
make keychown
```

### Replica Set
```bash
$(printf "`echo IP{0..2}=%s`" x.x.x.{5..7})
make run IP0=x.x.x.5 IP1=x.x.x.6 IP2=x.x.x.7 && make log
make rs-status
make rs-init
```

### Users

```bash
# create admin
make run IP0=x.x.x.5 IP1=x.x.x.6 IP2=x.x.x.7 AUTH= KEYFILE= && make log
make admin

# create user
make user DB=<db-name> USER=<user-name>

# login shell
make shell DB=admin USER=admin
make shell DB=<db-name> USER=<user-name>
```

### Dump/Restore

```bash
make dump IP0=x.x.x.x DB=<db-name> USER=<user-name>

# .
# |-README.md
# ├─Makefile
# ├─...
# ├─dump-xxxxxxxxxx.tar
# └─dump
#    └───<db-name>
#         └───*.json/*.bson

make untar xxx.tar
make restore IP0=x.x.x.x DB=<db-name> USER=<user-name>
```
