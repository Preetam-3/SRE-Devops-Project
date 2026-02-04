resource "aws_iam_role" "projectrole1" {
  name = "test_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_role_policy" "projectrolepolicy1" {
  name = "projectrole1"
  role = aws_iam_role.projectrole1.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:DeleteBucket",
          "s3:PutObject",
        ]
        Effect = "Allow"
        Resource = ["arn:aws:s3:::projectbucket1","arn:aws:s3:::projectbucket1/*"]
        
      }
    ]
  })
}

resource "aws_iam_instance_profile" "projectprofile1" {
  name = "project_profile-1"
  role = aws_iam_role.projectrole1.id
}

