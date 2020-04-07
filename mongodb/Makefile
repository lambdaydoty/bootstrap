IMAGE=mongo:4-bionic
NAME=mongo
PORT=27017

HOST_DATADIR="`pwd`/data/db"
GUEST_DATADIR=/data/db
RS_NAME=rs

KEYFILE=keyfile
ID=999

test:
	@echo $(shell pwd)/123

keygen:
	@openssl rand -base64 755 > $(KEYFILE)
	@chmod 400 $(KEYFILE)
	@sudo chown $(ID) $(KEYFILE)
	@sudo chgrp $(ID) $(KEYFILE)
	@ls -al $(KEYFILE)

keyexist:
	[ -f $(KEYFILE) ]

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
		$(IMAGE) \
    			--auth \
    			--replSet $(RS_NAME) \
    			--keyFile "/data/$(KEYFILE)"

stop:
	docker stop $(NAME) --time 30 || true

log:
	docker logs --follow $(NAME)

admin:
	docker exec -it $(NAME) mongo --host localhost

#ping:
#	@curl \
#		--silent \
#		--header "Content-Type: application/json" \
#		--data '{"method":"eth_blockNumber","params":[],"id":1,"jsonrpc":"2.0"}' \
#		--request POST \
#		$(URL) \
#			| jq '.result' \
#			| xargs printf "%d"
#
#head:
#	$(eval TIMESTAMP := $(shell date +"%s"))
#	@curl -s "https://api.etherscan.io/api?module=block&action=getblocknobytime&closest=before&timestamp=$(TIMESTAMP)" \
#		| jq '.result' \
#		| xargs
#
#enode:
#	@curl \
#		--silent \
#		--header "Content-Type: application/json" \
#		--data '{"method":"parity_enode","params":[],"id":1,"jsonrpc":"2.0"}' \
#		--request POST \
#		$(URL) \
#			| jq '.result' \
#			| xargs printf "%s"
