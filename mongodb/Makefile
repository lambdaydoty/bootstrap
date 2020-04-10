IMAGE=mongo:4
NAME=mongo
PORT?=27017

HOST_DATADIR="`pwd`/data/db"
GUEST_DATADIR=/data/db
RS=rs
RS_HOST=$(RS)/db0,db1,db2

KEYFILE=keyfile
ID=999

AUTH?=--auth
KEY?=--keyFile /data/$(KEYFILE)

IP0?=127.0.0.1
IP1?=127.0.0.1
IP2?=127.0.0.1

## keyfile ##

keygen: keyinexist
	@openssl rand -base64 755 > $(KEYFILE)
	@chmod 400 $(KEYFILE)
	@ls -al $(KEYFILE)

keychown: keyexist
	@sudo chown $(ID) $(KEYFILE)
	@sudo chgrp $(ID) $(KEYFILE)
	@ls -al $(KEYFILE)

## mongod ##

run: stop keyexist
	docker pull $(IMAGE)
	docker rm $(NAME) || true
	docker run \
		--name $(NAME) \
		--detach \
		--restart unless-stopped \
		--publish $(PORT):$(PORT) \
		--volume $(shell pwd)/$(KEYFILE):/data/$(KEYFILE) \
		--volume $(HOST_DATADIR):$(GUEST_DATADIR) \
		--add-host db0:$(IP0) \
		--add-host db1:$(IP1) \
		--add-host db2:$(IP2) \
		$(IMAGE) \
			--replSet $(RS) \
			$(AUTH) \
			$(KEY)

stop:
	docker stop $(NAME) --time 30 || true

log:
	docker logs --follow $(NAME)

## replica set ##

rs_init=$(shell printf ' \
  var cfg = { \
    "_id": "$(RS)", \
    "version": 1, \
    "members": [ \
      { "_id": 0, "host": "db0:27017", "priority": 2 }, \
      { "_id": 1, "host": "db1:27017", "priority": 0 }, \
      { "_id": 2, "host": "db2:27017", "priority": 0 } \
    ] \
  }; \
  rs.initiate(cfg, { force: true }); \
')
# rs.reconfig(cfg, { force: true });
# db.getMongo().setReadPref('nearest');

rs-status:
	docker exec $(NAME) \
		mongo \
			--host localhost \
			--eval 'rs.status()'
rs-init:
	docker exec $(NAME) \
		mongo \
			--host localhost \
			--eval '$(rs_init)'

## users ##

create_admin=$(shell printf ' \
  db.createUser({ \
    user: "admin", \
    pwd: passwordPrompt(), \
    roles: ["root"] \
  }); \
')

admin:
	@echo ""
	@echo $(shell openssl rand -base64 32)
	@echo $(shell openssl rand -base64 32)
	@echo $(shell openssl rand -base64 32)
	@echo ""
	docker exec -it $(NAME) \
		mongo admin \
			--host $(RS_HOST) \
			--eval '$(create_admin)'

DB?=<db-name-here>
USER?=<user-name-here>

create_user=$(shell printf ' \
  db.createUser({ \
    user: "$(USER)", \
    pwd: passwordPrompt(), \
    roles: [ { role: "readWrite", db: "$(DB)" } ] \
  }); \
')

user:
	@echo "Create a new user..."
	@echo
	@echo "dbname=$(DB)"
	@echo "username=$(USER)"
	@echo "password?= $(shell openssl rand -base64 32)"
	@echo
	@echo "First enter the admin password..."
	@echo ""
	docker exec -it $(NAME) \
		mongo $(DB) \
			--authenticationDatabase admin \
			--host $(RS_HOST) \
			--username admin \
			--eval '$(create_user)'

PORT0?=$(PORT)
PORT1?=$(PORT)
PORT2?=$(PORT)
URI?=mongodb://$(USER)@db0:$(PORT0),db1:$(PORT1),db2:$(PORT2)/$(DB)?replicaSet=$(RS)
NETWORK?=bridge

shell:
	@echo "Parameters: IPx?=... PORTx?=... DB= USER="
	@echo ""
	@echo $(URI)
	@echo ""
	docker stop $(DB)-$(USER) || true
	docker rm $(DB)-$(USER) || true
	docker run \
		-it \
		--network $(NETWORK) \
		--add-host db0:$(IP0) \
		--add-host db1:$(IP1) \
		--add-host db2:$(IP2) \
		--name shell-$(DB) \
		$(IMAGE) mongo "$(URI)"

## dump/restore ##

DUMP_PATH?=$(shell pwd)/dump

untar:
	@echo "Parameters: FILE=..."
	@tar xvf $(FILE)

restore:
	@echo "Parameters: IP0=... DB=... USER=..."
	@echo ""
	@echo "Make sure the dump dir has tree structure as:"
	@echo ".../dump/<db-name>/*.{json,bson}"
	@echo ""
	docker run \
		-it \
		--rm \
		--volume $(DUMP_PATH):/dump \
		--add-host db0:$(IP0) \
		$(IMAGE) mongorestore /dump/$(DB) \
			--host $(IP0) \
			--port $(PORT) \
			--db $(DB) \
			--username $(USER)

dump:
	@echo "Parameters: IP0=... DB=... USER=..."
	@echo ""
	mkdir $(DUMP_PATH) || true
	sudo chown $(ID) $(DUMP_PATH)
	docker run \
		-it \
		--rm \
		--volume $(DUMP_PATH):/dump \
		--add-host db0:$(IP0) \
		$(IMAGE) mongodump \
			--out /dump \
			--host $(IP0) \
			--port $(PORT) \
			--db $(DB) \
			--username $(USER)
	@ls -al $(DUMP_PATH)
	@tar cvf dump-$(shell date +'%s').tar $(DUMP_PATH)

## triplet ##

TR_RS=triplet
TR_HOST=localhost
TR_PORT0=37017
TR_PORT1=37018
TR_PORT2=37019
tr_init=$(shell printf ' \
  var cfg = { \
    "_id": "$(TR_RS)", \
    "version": 1, \
    "members": [ \
      { "_id": 0, "host": "$(TR_HOST):$(TR_PORT0)" }, \
      { "_id": 1, "host": "$(TR_HOST):$(TR_PORT1)" }, \
      { "_id": 2, "host": "$(TR_HOST):$(TR_PORT2)" } \
    ] \
  }; \
  rs.initiate(cfg, { force: true }); \
')

TR_URI=mongodb://$(TR_HOST):$(TR_PORT0),$(TR_HOST):$(TR_PORT1),$(TR_HOST):$(TR_PORT2)/$(DB)?replicaSet=$(TR_RS)

triplet: stop-triplet
	docker run --detach --network host --name triplet0 $(IMAGE) --replSet $(TR_RS) --port $(TR_PORT0) --bind_ip_all
	docker run --detach --network host --name triplet1 $(IMAGE) --replSet $(TR_RS) --port $(TR_PORT1) --bind_ip_all
	docker run --detach --network host --name triplet2 $(IMAGE) --replSet $(TR_RS) --port $(TR_PORT2) --bind_ip_all
	sleep 3
	docker exec -it triplet0 mongo --host $(TR_HOST) --port $(TR_PORT0) --eval '$(tr_init)'
	docker exec -it triplet0 mongo --host $(TR_HOST) --port $(TR_PORT0) --eval 'rs.status()'
	@echo "DB_URI=$(TR_URI)"

stop-triplet:
	docker stop triplet0 || true
	docker stop triplet1 || true
	docker stop triplet2 || true
	docker rm triplet0 || true
	docker rm triplet1 || true
	docker rm triplet2 || true

## helpers ##

keyexist:
	[ -f $(KEYFILE) ]

keyinexist:
	! [ -f $(KEYFILE) ]
