.PHONY: all env virtualenv install

SHELL := /usr/bin/env bash
HELIUM_CLI := $(shell pwd)/bin

all: env virtualenv install

env:
	cp -n ansible/group_vars/devbox.yml.example ansible/group_vars/devbox.yml | true
	cp -n ansible/hosts.example ansible/hosts | true

virtualenv:
	if [ ! -d ".venv" ]; then \
		python3 -m pip install virtualenv --user; \
        python3 -m virtualenv .venv; \
	fi

install: env virtualenv
	( \
		source .venv/bin/activate; \
		python -m pip install -r requirements.txt; \
		\
		if ! cat ~/.bash_profile | grep -q "$(HELIUM_CLI)" ; then echo "export PATH=\"$(HELIUM_CLI):\$$PATH\"" >> ~/.bash_profile ; fi; \
		\
		bin/helium-cli update; \
		vagrant up; \
		mkdir -p ~/.ssh; \
		if ! cat ~/.ssh/config | grep -xqFe "Host heliumedu.test" ; then vagrant ssh-config --host heliumedu.test >> ~/.ssh/config ; fi; \
		bin/helium-cli deploy master devbox; \
	)
