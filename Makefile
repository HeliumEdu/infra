.PHONY: all install start

SHELL := /usr/bin/env bash
HELIUMCLI_PROJECTS ?= '["platform", "frontend", "ci-tests"]'
SKIP_UPDATE ?= 'false'

all: install start

install:
	@python -m pip install -r requirements.txt

	@HELIUMCLI_FORCE_FETCH=True HELIUMCLI_SKIP_UPDATE_PULL=True HELIUMCLI_PROJECTS=$(HELIUMCLI_PROJECTS) helium-cli update-projects

build:
	cd projects/platform && make build-docker
	cd projects/frontend && make build-docker

start:
	cd projects/platform && ./bin/runserver
	cd projects/frontend && ./bin/runserver

publish:
	cd projects/platform && make publish-docker
	cd projects/frontend && make publish-docker