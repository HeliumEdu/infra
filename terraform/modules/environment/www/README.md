# module: environment/www

Marketing site (`landing.${env_prefix}heliumedu.com`, eventually `heliumedu.com` / `www.heliumedu.com`) — S3 bucket, CloudFront distribution, Route 53 record.

Source repo: [HeliumEdu/www](https://github.com/HeliumEdu/www) (Astro/AstroWind static site).

## Wiring it up

1. **Add a SAN to the ACM cert** in `modules/environment/certificatemanager/main.tf`:

   ```hcl
   subject_alternative_names = [
     "www.${var.route53_heliumedu_com_zone_name}",
     "api.${var.route53_heliumedu_com_zone_name}",
     "app.${var.route53_heliumedu_com_zone_name}",
     "support.${var.route53_heliumedu_com_zone_name}",
     "landing.${var.environment_prefix}${var.route53_heliumedu_com_zone_name}",  # NEW
   ]
   ```

   (Add the same SAN to the `heliumstudy_com` cert if you want `landing.heliumstudy.com` to redirect to `landing.heliumedu.com` via the existing redirect bucket pattern. Optional.)

2. **Add the module call** in `environments/{prod,dev}/main.tf`:

   ```hcl
   module "www" {
     source = "../../modules/environment/www"

     environment                     = var.environment
     environment_prefix              = var.environment_prefix
     route53_heliumedu_com_zone_id   = module.route53.heliumedu_com_zone_id
     route53_heliumedu_com_zone_name = module.route53.heliumedu_com_zone_name
     heliumedu_com_cert_arn          = module.certificatemanager.heliumedu_com_cert_arn
   }
   ```

3. **Apply** (`terraform plan` first to verify the cert SAN re-validation is the only delta beyond the new bucket/distribution).

## Cutover (2026-08-01)

When the legacy `frontend-legacy` repo is decommissioned:

1. Set `module.www.is_landing_alias_enabled = false` to remove the `landing.*` distribution.
2. In `modules/environment/cloudfront/main.tf`, change the origin of `aws_cloudfront_distribution.heliumedu_frontend` from `var.s3_website_endpoint` (legacy bucket) to the www bucket — pass `module.www.heliumedu_s3_www_website_endpoint` from `environments/{env}/main.tf`. The `www.heliumedu.com` and apex `heliumedu.com` aliases stay attached to the same distribution.
3. Optionally remove `landing.${env_prefix}heliumedu.com` from the cert SANs (re-validation again).
4. Update the deploy workflow's CloudFront alias lookup to find the apex/www distribution (already supported — the workflow tries `landing.*`, apex, and `www.*` in order).
5. Decommission `heliumedu.${env}.frontend.static` (legacy bucket) once you're confident.
