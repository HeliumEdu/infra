#!/usr/bin/env python

__copyright__ = "Copyright (c) 2018 Helium Edu"
__license__ = "MIT"

import os

BASE_DIR = os.path.normpath(os.path.join(os.path.abspath(os.path.dirname(__file__)), '..'))


def main():
    hosts_in_path = os.path.join(os.path.join(BASE_DIR, "ansible", "hosts", "stage.example"))
    hosts_out_path = os.path.join(os.path.join(BASE_DIR, "ansible", "hosts", "stage"))
    with open(hosts_in_path, "r") as f:
        s = f.read()
    for var in ["EC2_USER",
                "FRONTEND_PUBLIC_DNS",
                "FRONTEND_IP_ADDRESS",
                "PLATFORM_WEB_PUBLIC_DNS",
                "PLATFORM_WEB_IP_ADDRESS",
                "PLATFORM_WORKER_PUBLIC_DNS",
                "PLATFORM_WORKER_IP_ADDRESS"]:
        s = s.replace("{%" + var + "%}", os.environ.get(var))
    with open(hosts_out_path, "w") as f:
        f.write(s)

    frontend_in_path = os.path.join(os.path.join(BASE_DIR, "ansible", "group_vars", "frontend.yml.example"))
    frontend_out_path = os.path.join(os.path.join(BASE_DIR, "ansible", "group_vars", "frontend.yml"))
    with open(frontend_in_path, "r") as f:
        s = f.read()
    for var in ["DOMAIN_ENVIRONMENT",
                "HELIUM_HOST",
                "PROJECT_DATADOG_API_KEY",
                "PROJECT_DATADOG_APP_KEY",
                "PLATFORM_ROLLBAR_POST_SERVER_ITEM_ACCESS_TOKEN",
                "PLATFORM_DB_HOST",
                "PLATFORM_DB_USER",
                "PLATFORM_DB_PASSWORD",]:
        s = s.replace("{%" + var + "%}", os.environ.get(var))
    with open(frontend_out_path, "w") as f:
        f.write(s)

    platform_in_path = os.path.join(os.path.join(BASE_DIR, "ansible", "group_vars", "platform.yml.example"))
    platform_out_path = os.path.join(os.path.join(BASE_DIR, "ansible", "group_vars", "platform.yml"))
    with open(platform_in_path, "r") as f:
        s = f.read()
    for var in ["DOMAIN_ENVIRONMENT",
                "HELIUM_HOST",
                "PROJECT_DATADOG_API_KEY",
                "PROJECT_DATADOG_APP_KEY",
                "PLATFORM_ROLLBAR_POST_SERVER_ITEM_ACCESS_TOKEN",
                "PLATFORM_DB_HOST",
                "PLATFORM_DB_USER",
                "PLATFORM_DB_PASSWORD",
                "PLATFORM_AWS_S3_ACCESS_KEY_ID",
                "PLATFORM_AWS_S3_SECRET_ACCESS_KEY",
                "PLATFORM_TWILIO_ACCOUNT_SID",
                "PLATFORM_TWILIO_AUTH_TOKEN",
                "PLATFORM_TWILIO_SMS_FROM",
                "PLATFORM_SECRET_KEY",
                "PLATFORM_CSRF_MIDDLEWARE_SECRET",
                "PLATFORM_EMAIL_HOST_USER",
                "PLATFORM_EMAIL_HOST_PASSWORD",
                "PLATFORM_REDIS_HOST"]:
        s = s.replace("{%" + var + "%}", os.environ.get(var))
    with open(platform_out_path, "w") as f:
        f.write(s)


if __name__ == "__main__":
    main()
