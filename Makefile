SHELL := /bin/bash

PROJECT_ID := realtime

default: build deploy status

build:
	@echo
	@echo "--------------------------"
	@echo "Building"
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID) build

ansible-check:
	@echo "Check ansible command"
	@ansible -i ansible/development/hosts all -m ping
	@ansible-playbook -i ansible/development/hosts ansible/development/site.yml --check --list-tasks --list-hosts $(ANSIBLE_ARGS)

setup-ansible:
	@echo "Setup configurations using ansible"
	@ansible-playbook -i ansible/development/hosts ansible/development/site.yml -v $(ANSIBLE_ARGS)

up:
	@echo
	@echo "--------------------------"
	@echo "Bringing up fresh instances"
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID) up -d btsync
	@docker-compose -p $(PROJECT_ID) up -d bnpb-sync
	@docker-compose -p $(PROJECT_ID) up -d bmkg-sync
	@docker-compose -p $(PROJECT_ID) up -d shakemaps-corrected-sync
	@docker-compose -p $(PROJECT_ID) up -d shakemaps-extracted-sync
	@docker-compose -p $(PROJECT_ID) up -d shakemaps-corrected-extracted-sync
	@docker-compose -p $(PROJECT_ID) up -d floodmaps-sync
	@docker-compose -p $(PROJECT_ID) up -d ashmaps-sync
	@docker-compose -p $(PROJECT_ID) up -d sftp
	@docker-compose -p $(PROJECT_ID) up -d --force-recreate apache
	@docker-compose -p $(PROJECT_ID) up -d --force-recreate inasafe

deploy: up bmkg-monitor inasafe-worker status

bmkg-monitor:
	@docker-compose -p $(PROJECT_ID) up -d inasafe-shakemap-monitor
	@docker-compose -p $(PROJECT_ID) up -d inasafe-shakemap-corrected-monitor
	@docker-compose -p $(PROJECT_ID) stop inasafe-shakemap-monitor-bnpb

bnpb-monitor:
	@docker-compose -p $(PROJECT_ID) up -d inasafe-shakemap-monitor-bnpb
	@docker-compose -p $(PROJECT_ID) up -d inasafe-shakemap-corrected-monitor
	@docker-compose -p $(PROJECT_ID) stop inasafe-shakemap-monitor

down:
	@docker-compose -p $(PROJECT_ID) down

checkout:
	@echo
	@echo "--------------------------"
	@echo "Checkout InaSAFE develop "
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID) run --rm inasafe /start.sh checkout realtime-backport-cherry-pick

inasafe-env:
	@docker-compose -p $(PROJECT_ID) exec inasafe /bin/bash -c "source run-env-realtime.sh && printenv"

inasafe-shakemap:
	@echo
	@echo "--------------------------"
	@echo "Running InaSAFE Assesment"
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID) run --rm inasafe /start.sh make-latest-shakemap

inasafe-floodmap:
	@echo
	@echo "--------------------------"
	@echo "Running InaSAFE Assesment"
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID) run --rm inasafe /start.sh make-latest-floodmap

inasafe-worker:
	@echo
	@echo "--------------------------"
	@echo "Running InaSAFE Workers"
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID) up -d --force-recreate inasafe-worker

inasafe-worker-log:
	@echo
	@echo "--------------------------"
	@echo "View Logs InaSAFE Workers"
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID) logs -f --tail=50 inasafe-worker

restart-inasafe-worker: stop-inasafe-worker
	@echo
	@echo "--------------------------"
	@echo "Hard Restart InaSAFE Workers"
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID) rm inasafe-worker
	@docker-compose -p $(PROJECT_ID) up -d --force-recreate inasafe-worker

stop-inasafe-worker:
	@echo
	@echo "--------------------------"
	@echo "Hard Stop InaSAFE Workers"
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID) stop inasafe-worker


inasafe-shell:
	@echo
	@echo "--------------------------"
	@echo "Running InaSAFE Shell"
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID) run --rm inasafe /bin/bash

bmkg-monitor-log:
	@echo
	@echo "--------------------------"
	@echo "Viewing shakemaps monitor logs"
	@echo "Latest lines, and follow logs"
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID) logs -f --tail=50 inasafe-shakemap-monitor

bnpb-monitor-log:
	@echo
	@echo "--------------------------"
	@echo "Viewing shakemaps monitor logs"
	@echo "Latest lines, and follow logs"
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID) logs -f --tail=50 inasafe-shakemap-monitor-bnpb

status:
	@echo
	@echo "--------------------------"
	@echo "Show status of all containers"
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID) ps

sftp-credential:
	@echo
	@echo "--------------------------"
	@echo "Show sftp credential"
	@echo "--------------------------"
	@docker-compose -p $(PROJECT_ID) exec sftp cat /credentials

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
	@docker-compose -p $(PROJECT_ID) kill
	@docker-compose -p $(PROJECT_ID) rm
