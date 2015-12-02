SHELL := /bin/bash

PROJECT_ID := realtime

CONF_FILE := -f docker-compose.yml
CONF_HELP := Uses docker-compose.yml

ifeq ($(MODE),dev)
	MODE_HELP := Using Development Environment. Use docker-compose-dev.yml
	CONF_FILE += -f docker-compose-dev.yml
	MODE_STRING := development
else
	MODE_HELP := Using Production Environment.
	MODE_STRING := production
endif

confinfo:
	@echo
	@echo $(CONF_HELP)
	@echo $(MODE_HELP)

default: build deploy status

build:
	@echo
	@echo "--------------------------"
	@echo "Building in $(MODE_STRING) mode"
	@echo "--------------------------"
	@docker-compose $(CONF_FILE) -p $(PROJECT_ID) build

deploy:
	@echo
	@echo "--------------------------"
	@echo "Bringing up fresh instances"
	@echo "--------------------------"
	@docker-compose $(CONF_FILE) -p $(PROJECT_ID) up -d btsync
	@docker-compose $(CONF_FILE) -p $(PROJECT_ID) up -d sftp
	@docker-compose $(CONF_FILE) -p $(PROJECT_ID) up -d apache
	@docker-compose $(CONF_FILE) -p $(PROJECT_ID) up -d inasafe
	# run shakemaps_monitor service
	@docker-compose $(CONF_FILE) -p $(PROJECT_ID) run -d inasafe /bin/sh -c "/shakemaps_monitor.sh /home/realtime/shakemaps" > .shakemonitor-id

checkout:
	@echo
	@echo "--------------------------"
	@echo "Checkout InaSAFE develop "
	@echo "--------------------------"
	@docker-compose $(CONF_FILE) -p $(PROJECT_ID) run --rm inasafe /start.sh checkout develop

inasafe-shakemap:
	@echo
	@echo "--------------------------"
	@echo "Running InaSAFE Assesment"
	@echo "--------------------------"
	@docker-compose $(CONF_FILE) -p $(PROJECT_ID) run --rm inasafe /start.sh make-latest-shakemap

inasafe-floodmap:
	@echo
	@echo "--------------------------"
	@echo "Running InaSAFE Assesment"
	@echo "--------------------------"
	@docker-compose $(CONF_FILE) -p $(PROJECT_ID) run --rm inasafe /start.sh make-latest-floodmap

inasafe-shell:
	@echo
	@echo "--------------------------"
	@echo "Running InaSAFE Shell"
	@echo "--------------------------"
	@docker-compose $(CONF_FILE) -p $(PROJECT_ID) run --rm inasafe /bin/bash

monitor-log:
	@echo
	@echo "--------------------------"
	@echo "Viewing shakemaps monitor logs"
	@echo "--------------------------"
	@docker logs $(PROJECT_ID)_inasafe_run_1

status:
	@echo
	@echo "--------------------------"
	@echo "Show status of all containers"
	@echo "--------------------------"
	@docker-compose $(CONF_FILE) -p $(PROJECT_ID) ps

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
	@echo "Killing $(MODE_STRING) instance!!! "
	@echo "--------------------------"
	$(eval monitor_id=$(shell cat .shakemonitor-id))
	@docker kill $(monitor_id)
	@docker rm $(monitor_id)
	@docker-compose $(CONF_FILE) -p $(PROJECT_ID) kill
	@docker-compose $(CONF_FILE) -p $(PROJECT_ID) rm
