provider "aws" {
  region = "us-east-1"  # Region for the source bucket
}

resource "aws_s3_bucket" "source" {
  bucket = "my-verizon-home-source"

  versioning {
    enabled = "true"
  }
}
provider "aws" {
  alias  = "replica"
  region = "us-west-2"  # Region for the destination bucket
}

resource "aws_s3_bucket" "destination" {
  provider = aws.replica
  bucket   = "my-verizon-home-destination"

   versioning{
    enabled = "true"

   }
   
}
resource "aws_iam_role" "replication_role" {    # creating a role 
  name = "s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "replication_policy" {  # creating a policy 
  name        = "s3-replication-policy"
  description = "Policy for S3 bucket replication"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging",
          "s3:GetObjectVersionTagging",
          "s3:GetObjectVersion",
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.source.arn}/*"
      },
      {
        Action   = "s3:ReplicateObject"
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.destination.arn}/*"
      },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "replication_policy_attachment" {  # attaching role with a policy
  role       = aws_iam_role.replication_role.name
  policy_arn = aws_iam_policy.replication_policy.arn
}

resource "aws_s3_bucket_replication_configuration" "replication" { # configuration of s3 replication
  role = aws_iam_role.replication_role.arn
  bucket = aws_s3_bucket.source.id

  rule {
    id     = "replication-rule"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.destination.arn
      storage_class = "STANDARD"
    }

    filter {
      prefix = ""
    }
    delete_marker_replication {
      status = "Enabled"
    }
  }
}


