.PHONY: all env install start test

SHELL := /usr/bin/env bash
HELIUMCLI_PROJECTS ?= '["platform", "frontend", "ci-tests"]'

all: env install start

env:
	cp -n ansible/group_vars/devbox.yml.example ansible/group_vars/devbox.yml | true

install: env
	@python -m pip install -r requirements.txt
	@ansible-galaxy install --force Datadog.datadog,2.2.0

	@HELIUMCLI_PROJECTS=$(HELIUMCLI_PROJECTS) helium-cli update-projects

	@vagrant plugin install vagrant-hostsupdater
	@vagrant plugin install vagrant-host-shell

start:
	@vagrant up
	@mkdir -p ~/.ssh
	@if ! cat ~/.ssh/config | grep -xqFe "Host heliumedu.test" ; then vagrant ssh-config --host heliumedu.test >> ~/.ssh/config ; fi
	@helium-cli deploy-build master devbox

test:
	@if [ ! -f ansible/devbox.yml ] ; then echo "ansible/devbox.yml not found" & exit 1 ; fi
	@if [ ! -f ansible/group_vars/devbox.yml ] ; then echo "ansible/group_vars/devbox.yml not found" & exit 1 ; fi
	@if [ ! -f ansible/hosts/devbox ] ; then echo "ansible/hosts/devbox not found" & exit 1 ; fi

	@python -c "import heliumcli" || (echo "helium-cli not installed"; exit 1)
	@if [ ! -d projects ] ; then echo "projects directory not found" & exit 1 ; fi

	@ansible-playbook ansible/devbox.yml --syntax-check
	@vagrant validate
