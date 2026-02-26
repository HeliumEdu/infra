.PHONY: all install-reqs install build start test-cluster-legacy

SHELL := /usr/bin/env bash
PYTHON_BIN := python
HELIUMCLI_PROJECTS ?= '["platform", "frontend", "cluster-tests", "frontend-legacy"]'
SKIP_UPDATE ?= 'false'
DEV_LOCAL_AWS_REGION ?= 'us-east-2'
PLATFORM ?= arm64
PROJECT_APP_LEGACY_HOST ?= http://localhost:3000

all: install start

install-reqs:
	$(PYTHON_BIN) -m pip install -r requirements.txt

install: install-reqs
	$(PYTHON_BIN) -m pip install -r requirements.txt

	@HELIUMCLI_FORCE_FETCH=True HELIUMCLI_SKIP_UPDATE_PULL=True HELIUMCLI_PROJECTS=$(HELIUMCLI_PROJECTS) helium-cli update-projects

build: install
	PLATFORM=$(PLATFORM) make -C projects/platform build-docker
	PLATFORM=$(PLATFORM) make -C projects/frontend build-docker

start:
	cd projects/platform && ./bin/runserver
	cd projects/frontend && ./bin/runserver

stop:
	make -C projects/platform stop-docker
	make -C projects/frontend stop-docker
	make -C projects/frontend-legacy stop-docker

restart: stop start

start-legacy:
	cd projects/frontend-legacy && ./bin/runserver

test-cluster-legacy:
	@if [[ -z "${PLATFORM_EMAIL_HOST_USER}" ]] || \
		[[ -z "${PLATFORM_EMAIL_HOST_PASSWORD}" ]] || \
		[[ -z "${PLATFORM_TWILIO_ACCOUNT_SID}" ]] || \
		[[ -z "${PLATFORM_TWILIO_AUTH_TOKEN}" ]] || \
		[[ -z "${PLATFORM_TWILIO_SMS_FROM}" ]] || \
		[[ -z "${AWS_INTEGRATION_S3_ACCESS_KEY_ID}" ]] || \
		[[ -z "${AWS_INTEGRATION_S3_SECRET_ACCESS_KEY}" ]] || \
		[[ -z "${CI_TWILIO_RECIPIENT_PHONE_NUMBER}" ]]; then \
  	  echo "Set all env vars required to run cluster tests end-to-end against a local Docker build: [\
PLATFORM_EMAIL_HOST_USER, \
PLATFORM_EMAIL_HOST_PASSWORD, \
PLATFORM_TWILIO_ACCOUNT_SID, \
PLATFORM_TWILIO_AUTH_TOKEN, \
PLATFORM_TWILIO_SMS_FROM, \
AWS_INTEGRATION_S3_ACCESS_KEY_ID, \
AWS_INTEGRATION_S3_SECRET_ACCESS_KEY, \
CI_TWILIO_RECIPIENT_PHONE_NUMBER]"; \
      exit 1; \
    fi

	./projects/platform/bin/provision-dot-env.sh

	make -C projects/platform run-docker
	make -C projects/frontend-legacy run-docker

	ENVIRONMENT=dev-local \
	PROJECT_APP_HOST=$(PROJECT_APP_LEGACY_HOST) \
    PROJECT_API_HOST=http://localhost:8000 \
    AWS_REGION=$(DEV_LOCAL_AWS_REGION) \
    make -C projects/cluster-tests test
