# 1.S3 bucket
resource "aws_s3_bucket" "terraform_state" {
  bucket = "hal-team-ec-tfstate-${random_id.bucket_suffix.hex}" # 중복 방지를 위해 랜덤 ID 추가
}

# 2. bucket version
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 3. DynamoDB table
resource "aws_s3_bucket" "terraform_locks" {
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}