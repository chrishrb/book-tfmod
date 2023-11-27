output "frontend_domain_name" {
  value = aws_s3_bucket_website_configuration.frontend_bucket.website_endpoint
}
