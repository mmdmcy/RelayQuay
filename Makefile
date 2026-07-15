ENV_FILE ?= /var/lib/relayquay/relayquay.env

.PHONY: check init doctor activate cover pause up down stop status logs config key

check:
	bash -n bin/relayquay
	./tests/profile-compatibility.sh

init:
	./bin/relayquay init

doctor:
	RELAYQUAY_ENV_FILE=$(ENV_FILE) ./bin/relayquay doctor

activate:
	RELAYQUAY_ENV_FILE=$(ENV_FILE) ./bin/relayquay activate

cover:
	RELAYQUAY_ENV_FILE=$(ENV_FILE) ./bin/relayquay cover

pause:
	RELAYQUAY_ENV_FILE=$(ENV_FILE) ./bin/relayquay pause

up:
	RELAYQUAY_ENV_FILE=$(ENV_FILE) ./bin/relayquay up

down:
	RELAYQUAY_ENV_FILE=$(ENV_FILE) ./bin/relayquay down

stop:
	RELAYQUAY_ENV_FILE=$(ENV_FILE) ./bin/relayquay stop

status:
	RELAYQUAY_ENV_FILE=$(ENV_FILE) ./bin/relayquay status

logs:
	RELAYQUAY_ENV_FILE=$(ENV_FILE) ./bin/relayquay logs

config:
	RELAYQUAY_ENV_FILE=$(ENV_FILE) ./bin/relayquay config

key:
	RELAYQUAY_ENV_FILE=$(ENV_FILE) ./bin/relayquay key
