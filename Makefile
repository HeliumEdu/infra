.PHONY: all install-reqs install build start validate fetch-support-articles

SHELL := /usr/bin/env bash
PYTHON_BIN := python
HELIUMCLI_PROJECTS ?= '["platform", "frontend", "www"]'
SKIP_UPDATE ?= 'false'
DEV_LOCAL_AWS_REGION ?= 'us-east-2'
PLATFORM ?= arm64

all: install start

install-reqs:
	$(PYTHON_BIN) -m pip install -r requirements.txt

install: install-reqs
	$(PYTHON_BIN) -m pip install -r requirements.txt

	@HELIUMCLI_FORCE_FETCH=True HELIUMCLI_SKIP_UPDATE_PULL=True HELIUMCLI_PROJECTS=$(HELIUMCLI_PROJECTS) helium-cli update-projects

build: install
	PLATFORM=$(PLATFORM) make -C projects/platform build-docker
	PLATFORM=$(PLATFORM) make -C projects/frontend build-docker

validate:
	@for env in dev dev-local global prod; do \
		echo "Validating terraform/environments/$${env}..."; \
		cd terraform/environments/$${env} && terraform init -backend=false && terraform validate && cd -; \
	done

start:
	cd projects/platform && ./bin/runserver
	cd projects/frontend && ./bin/runserver

stop:
	make -C projects/platform stop-docker
	make -C projects/frontend stop-docker

restart: stop start

fetch-support-articles: install-reqs
	$(PYTHON_BIN) scripts/fetch_support_articles.py
