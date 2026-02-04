resource "aws_s3_bucket" "projectbucket1" {
  bucket = "my-tf-project-bucket-1001"

  tags = {
    Name        = "My bucket"
    Environment = "Demo"
  }
}
