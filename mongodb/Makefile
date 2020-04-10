IMAGE=mongo:4-bionic
NAME=mongo
PORT=27017

HOST_DATADIR="`pwd`/data/db"
GUEST_DATADIR=/data/db
RS=rs
RS_HOST=$(RS)/db0,db1,db2

KEYFILE=keyfile
ID=999

AUTH?=--auth
KEY?=--keyFile /data/$(KEYFILE)

IP0?=ip0-here
IP1?=ip1-here
IP2?=ip2-here

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

DB?=db-name-here
USER?=user-name-here

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

shell:
	docker run \
		-it \
		--add-host db0:$(IP0) \
		--add-host db1:$(IP1) \
		--add-host db2:$(IP2) \
		$(IMAGE) mongo $(DB) \
			--host $(RS_HOST) \
			--username $(USER)

# /bin/bash -c "mkdir /home/mongodb && touch /home/mongodb/.dbshell && mongo --username $admin_name --host $RS_NAME/db0,db1,db2 --password"

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

triplet:
	docker run --detach --net=host --name triplet0 $(IMAGE) --replSet $(TR_RS) --port $(TR_PORT0) --bind_ip_all
	docker run --detach --net=host --name triplet1 $(IMAGE) --replSet $(TR_RS) --port $(TR_PORT0) --bind_ip_all
	docker run --detach --net=host --name triplet2 $(IMAGE) --replSet $(TR_RS) --port $(TR_PORT0) --bind_ip_all
	sleep 3
	docker run -it $(IMAGE) mongo --host $(TR_HOST) --port $(TR_PORT0) --eval '$(tr_init)'
	docker run -it $(IMAGE) mongo --host $(TR_HOST) --port $(TR_PORT0) --eval 'rs.status()'

## helpers ##

keyexist:
	[ -f $(KEYFILE) ]

keyinexist:
	! [ -f $(KEYFILE) ]
