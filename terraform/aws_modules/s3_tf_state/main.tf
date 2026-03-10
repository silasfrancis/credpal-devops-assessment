resource "aws_s3_bucket" "tf_state_bucket" {
  bucket = var.bucket_name
  force_destroy = false
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name = var.bucket_tag_name
  }
}

resource "aws_s3_object" "s3_object" {
  bucket = var.bucket_name
  key = var.bucket_key
}
