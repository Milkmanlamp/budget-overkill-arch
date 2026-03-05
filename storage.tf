resource "aws_dynamodb_table" "qoutes_table" {
  name = "${var.project_name}-qoutes-table"

  billing_mode = "PAY_PER_REQUEST"
  #i can make this provisioned if this get more predictable
  hash_key  = "PK"
  range_key = "SK"

  attribute {
    name = "PK"
    type = "S"
  }
  attribute {
    name = "SK"
    type = "S"
  }
  point_in_time_recovery {
    enabled = true
  }
  server_side_encryption {
    enabled = true
    #might use KMS later
  }
  deletion_protection_enabled = false #i will make true when im done testing
}


resource "aws_s3_bucket" "this" {
  bucket = "${var.project_name}-store"
  tags = {
    Name = "standard-store"
  }
}
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}
