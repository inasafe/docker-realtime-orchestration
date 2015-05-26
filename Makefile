SHELL := /bin/bash

default: build deploy status

build:
	@echo
	@echo "--------------------------"
	@echo "Building in production mode"
	@echo "--------------------------"
	@docker-compose -p realtime build

deploy:
	@echo
	@echo "--------------------------"
	@echo "Bringing up fresh instances"
	@echo "--------------------------"
	@docker-compose -p realtime up -d

checkout:
	@echo
	@echo "--------------------------"
	@echo "Checkout InaSAFE develop "
	@echo "--------------------------"
	@docker-compose -p realtime run --rm inasafe /start.sh checkout develop

inasafe:
	@echo
	@echo "--------------------------"
	@echo "Running InaSAFE Assesment"
	@echo "--------------------------"
	@docker-compose -p realtime run --rm inasafe

status:
	@echo
	@echo "--------------------------"
	@echo "Show status of all containers"
	@echo "--------------------------"
	@docker-compose -p realtime ps

sftp_credential:
	@echo
	@echo "--------------------------"
	@echo "Show sftp credential"
	@echo "--------------------------"
	@docker cp realtime_sftp_1:/credentials /tmp
	@cat /tmp/credentials
	@rm /tmp/credentials

rm:
	@echo
	@echo "--------------------------"
	@echo "Killing production instance!!! "
	@echo "--------------------------"
	@docker-compose -p realtime kill
	@docker-compose -p realtime rm
