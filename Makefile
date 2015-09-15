SHELL := /bin/bash

PROJECT_ID := realtime

default: build deploy status

build:
	@echo
	@echo "--------------------------"
	@echo "Building in production mode"
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID) build

dev-build:
	@echo
	@echo "--------------------------"
	@echo "Building in production mode"
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID)-dev build

deploy:
	@echo
	@echo "--------------------------"
	@echo "Bringing up fresh instances"
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID) up -d btsync
	@docker-compose -p $(PROJECT_ID) up -d sftp
	@docker-compose -p $(PROJECT_ID) up -d apache
	@docker-compose -p $(PROJECT_ID) up -d inasafe
	# run shakemaps_monitor service
	@docker-compose -p $(PROJECT_ID) run -d inasafe /bin/sh -c "/shakemaps_monitor.sh /home/realtime/shakemaps" > .shakemonitor-id

dev-deploy:
	@echo
	@echo "--------------------------"
	@echo "Bringing up fresh instances"
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID)-dev up -d btsync
	@docker-compose -p $(PROJECT_ID)-dev up -d sftp
	@docker-compose -p $(PROJECT_ID)-dev up -d apache
	@docker-compose -p $(PROJECT_ID)-dev up -d devinasafe
	# run shakemaps_monitor service
	@docker-compose -p $(PROJECT_ID)-dev run -d devinasafe /bin/sh -c "/shakemaps_monitor.sh /home/realtime/shakemaps" > .shakemonitor-id

checkout:
	@echo
	@echo "--------------------------"
	@echo "Checkout InaSAFE develop "
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID) run --rm inasafe /start.sh checkout develop

dev-checkout:
	@echo
	@echo "--------------------------"
	@echo "Checkout InaSAFE develop "
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID)-dev run --rm devinasafe /start.sh checkout develop

inasafe:
	@echo
	@echo "--------------------------"
	@echo "Running InaSAFE Assesment"
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID) run --rm inasafe /start.sh make-latest-shakemap

inasafe-shell:
	@echo
	@echo "--------------------------"
	@echo "Running InaSAFE Shell"
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID) run --rm inasafe /bin/bash

monitor-log:
	@echo
	@echo "--------------------------"
	@echo "Viewing shakemaps monitor logs"
	@echo "--------------------------"
	@docker logs $(PROJECT_ID)_inasafe_run_1

dev-monitor-log:
	@echo
	@echo "--------------------------"
	@echo "Viewing shakemaps monitor logs"
	@echo "--------------------------"
	@docker logs $(PROJECT_ID)dev_devinasafe_run_1

dev-inasafe:
	@echo
	@echo "--------------------------"
	@echo "Running InaSAFE Assesment in Dev Mode"
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID)-dev run --rm devinasafe /start.sh make-latest-shakemap

dev-inasafe-shell:
	@echo
	@echo "--------------------------"
	@echo "Running InaSAFE Shell in Dev Mode"
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID)-dev run --rm devinasafe /bin/bash

status:
	@echo
	@echo "--------------------------"
	@echo "Show status of all containers"
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID) ps

dev-status:
	@echo
	@echo "--------------------------"
	@echo "Show status of all containers"
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID)-dev ps

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
	$(eval monitor_id=$(shell cat .shakemonitor-id))
	@docker kill $(monitor_id)
	@docker rm $(monitor_id)
	@docker-compose -p $(PROJECT_ID) kill
	@docker-compose -p $(PROJECT_ID) rm

dev-rm:
	@echo
	@echo "--------------------------"
	@echo "Killing dev instance!!! "
	@echo "--------------------------"
	$(eval monitor_id=$(shell cat .shakemonitor-id))
	@docker kill $(monitor_id)
	@docker rm $(monitor_id)
	@docker-compose -p $(PROJECT_ID)-dev kill
	@docker-compose -p $(PROJECT_ID)-dev rm
