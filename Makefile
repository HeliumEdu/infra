.PHONY: all install start run-ci publish

SHELL := /usr/bin/env bash
HELIUMCLI_PROJECTS ?= '["platform", "frontend", "ci-tests"]'
SKIP_UPDATE ?= 'false'
DEV_LOCAL_AWS_REGION ?= 'us-east-2'
PLATFORM ?= linux/arm64

all: install start

install:
	@python -m pip install -r requirements.txt

	@HELIUMCLI_FORCE_FETCH=True HELIUMCLI_SKIP_UPDATE_PULL=True HELIUMCLI_PROJECTS=$(HELIUMCLI_PROJECTS) helium-cli update-projects

build:
	@rm -f projects/platform/.env
	PLATFORM=$(PLATFORM) make -C projects/platform build-docker
	PLATFORM=$(PLATFORM) make -C projects/frontend build-docker

start:
	cd projects/platform && ./bin/runserver
	cd projects/frontend && ./bin/runserver

run-ci:
	@if [[ -z "${PLATFORM_EMAIL_HOST_USER}" ]] || \
		[[ -z "${PLATFORM_EMAIL_HOST_PASSWORD}" ]] || \
		[[ -z "${PLATFORM_TWILIO_ACCOUNT_SID}" ]] || \
		[[ -z "${PLATFORM_TWILIO_AUTH_TOKEN}" ]] || \
		[[ -z "${PLATFORM_TWILIO_SMS_FROM}" ]] || \
		[[ -z "${CI_AWS_S3_ACCESS_KEY_ID}" ]] || \
		[[ -z "${CI_AWS_S3_SECRET_ACCESS_KEY}" ]] || \
		[[ -z "${CI_TWILIO_RECIPIENT_PHONE_NUMBER}" ]]; then \
  	  echo "Set all env vars required to run CI tests end-to-end against a local Docker build: [\
PLATFORM_EMAIL_HOST_USER, \
PLATFORM_EMAIL_HOST_PASSWORD, \
PLATFORM_TWILIO_ACCOUNT_SID, \
PLATFORM_TWILIO_AUTH_TOKEN, \
PLATFORM_TWILIO_SMS_FROM, \
CI_AWS_S3_ACCESS_KEY_ID, \
CI_AWS_S3_SECRET_ACCESS_KEY, \
CI_TWILIO_RECIPIENT_PHONE_NUMBER]"; \
      exit 1; \
    fi

	./projects/platform/bin/provision-dot-env.sh

	make -C projects/frontend run-docker

	make -C projects/platform run-docker
	# Kick the platform containers to ensure MySQL is healthy to receive migrations
	make -C projects/platform stop-docker run-docker
	# Wait to ensure migrations have run successfully
	sleep 15

	ENVIRONMENT=dev-local \
	PROJECT_APP_HOST=http://localhost:3000 \
    PROJECT_API_HOST=http://localhost:8000 \
    AWS_REGION=$(DEV_LOCAL_AWS_REGION) \
    make -C projects/ci-tests install test

publish:
	make -C projects/platform publish-docker
	make -C projects/frontend publish-docker
