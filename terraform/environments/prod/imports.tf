# One-time imports for resources that existed before being brought under Terraform management.
# These are safe to remove after the first successful apply.

import {
  to = module.ecs.aws_cloudwatch_log_group.platform
  id = "/ecs/helium_platform_prod"
}
