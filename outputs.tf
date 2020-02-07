output "url" {
  value = "https://${var.domain}/"
}
output "bucket" {
  value = aws_s3_bucket.site_bucket.id
}