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
	@docker-compose $(CONF_FILE) -p $(PROJECT_ID) run -d inasafe-shakemap-monitor /bin/sh -c "/shakemaps_monitor.sh /home/realtime/shakemaps" > .shakemonitor-id

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

inasafe-worker:
	@echo
	@echo "--------------------------"
	@echo "Running InaSAFE Workers"
	@echo "--------------------------"
	@docker-compose $(CONF_FILE) -p $(PROJECT_ID) up -d inasafe-worker

inasafe-worker-log:
	@echo
	@echo "--------------------------"
	@echo "View Logs InaSAFE Workers"
	@echo "--------------------------"
	@docker-compose $(CONF_FILE) -p $(PROJECT_ID) logs -f --tail=50 inasafe-worker

restart-inasafe-worker: stop-inasafe-worker
	@echo
	@echo "--------------------------"
	@echo "Hard Restart InaSAFE Workers"
	@echo "--------------------------"
	@docker-compose $(CONF_FILE) -p $(PROJECT_ID) rm inasafe-worker
	@docker-compose $(CONF_FILE) -p $(PROJECT_ID) up -d inasafe-worker

stop-inasafe-worker:
	@echo
	@echo "--------------------------"
	@echo "Hard Stop InaSAFE Workers"
	@echo "--------------------------"
	@docker-compose $(CONF_FILE) -p $(PROJECT_ID) kill inasafe-worker


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
	@echo "Latest 10 lines, and follow logs"
	@echo "--------------------------"
	@docker logs -f --tail=10 $(PROJECT_ID)_inasafe-shakemap-monitor_run_1

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
	@echo "Killing shakemap monitor"
	@for i in $$(docker ps -a | grep "realtime_inasafe-shakemap-monitor_run" | cut -f1 -d" "); \
		do docker rm -f $$i; \
	done
	@echo "Killing event processor"
	@for i in $$(docker ps -a | grep "realtime_inasafe_run" | cut -f1 -d" "); \
		do docker rm -f $$i; \
	done
	@docker-compose $(CONF_FILE) -p $(PROJECT_ID) kill
	@docker-compose $(CONF_FILE) -p $(PROJECT_ID) rm
