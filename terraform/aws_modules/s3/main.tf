resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
  force_destroy = false
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name = var.bucket_tag_name
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_bucket_config" {
    bucket = aws_s3_bucket.s3_bucket.id
    rule {
      id = var.bucket_rule_id
      status = "Enabled"
      abort_incomplete_multipart_upload {
        days_after_initiation = var.bucket_exp_days
      }
      expiration {
        days = var.bucket_exp_days
      }
    }
  
}

resource "aws_s3_object" "s3_object" {
  bucket = var.bucket_name
  key = var.bucket_key
}

resource "aws_s3_bucket_versioning" "bucket_versioning_config" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_server_side_config" {
    bucket = aws_s3_bucket.s3_bucket.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }  
}