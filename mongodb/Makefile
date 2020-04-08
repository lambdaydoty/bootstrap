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

test:
	@echo $(KEY)

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
	docker exec -it $(NAME) \
		mongo $(DB) \
			--host $(RS_HOST) \
			--username $(USER)

## helpers ##

keyexist:
	[ -f $(KEYFILE) ]

keyinexist:
	! [ -f $(KEYFILE) ]
