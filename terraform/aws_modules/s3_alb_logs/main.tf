resource "aws_s3_bucket" "alb_logs" {
  bucket = "${var.bucket_name}-alb-logs"
}
