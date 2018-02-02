.PHONY: all env install

all: env install

env:
	cp -n ansible/group_vars/devbox.yml.example ansible/group_vars/devbox.yml | true
	cp -n ansible/hosts.example ansible/hosts | true

install: env
	python -m pip install -r requirements.txt --user
	bin/helium-cli update
	vagrant up
	if ! cat ~/.ssh/config | grep -xqFe "Host heliumedu.dev" ; then vagrant ssh-config --host heliumedu.dev >> ~/.ssh/config ; fi
	bin/helium-cli deploy master devbox
