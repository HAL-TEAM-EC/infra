# EC-SITE Infrastructure

This Terraform configuration currently manages the frontend hosting layer:

- Private S3 bucket for Vite/React build files
- CloudFront distribution
- Origin Access Control so S3 is not public
- Security headers policy
- SPA fallback from `403` and `404` to `/index.html`

Backend infrastructure is intentionally not created yet because the `backend`
directory does not contain a runnable Laravel application.

## Basic commands

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

## Deploy frontend assets

After `terraform apply`, build and upload the frontend:

```bash
cd ../frontend
npm run build
aws s3 sync dist "s3://$(terraform -chdir=../infra output -raw frontend_bucket_name)" --delete
aws cloudfront create-invalidation \
  --distribution-id "$(terraform -chdir=../infra output -raw cloudfront_distribution_id)" \
  --paths "/*"
```

## Custom domain

If you use a custom domain, create an ACM certificate in `us-east-1` and pass:

```bash
terraform apply \
  -var='custom_domain_names=["example.com"]' \
  -var='acm_certificate_arn=arn:aws:acm:us-east-1:...'
```
