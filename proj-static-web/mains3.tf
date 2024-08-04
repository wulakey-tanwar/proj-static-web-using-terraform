terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.58.0"
    }
      random = {
        source = "hashicorp/random"
        version = "3.6.2"
      }
    }
}
#change provider according to your region
provider "aws" {
  region = "us-east-1"

}
resource "random_id" "rand_id" {
    byte_length = 8
}
resource "aws_s3_bucket" "mywebsite-bucket" {
    bucket = "mywebsite-bucket-${random_id.rand_id.hex}"
  
}
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.mywebsite-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
resource "aws_s3_bucket_policy" "mywebsite" {
    bucket = aws_s3_bucket.mywebsite-bucket.id
    policy = jsonencode(
    {
    Version = "2012-10-17",
    Statement = [
        {
            Sid = "PublicReadGetObject",
            Effect = "Allow",
            Principal = "*",
            Action = "s3:GetObject",
            Resource ="arn:aws:s3:::${aws_s3_bucket.mywebsite-bucket.id}/*"
        }
      ]
    }

  )
}
resource "aws_s3_bucket_website_configuration" "mywebsite" {
  bucket = aws_s3_bucket.mywebsite-bucket.id

  index_document {
    suffix = "index.html"
  }

}

resource "aws_s3_object" "index_html" {
    bucket = aws_s3_bucket.mywebsite-bucket.bucket  
    source ="./index.html"
    key ="index.html"
    content_type = "text/html"
}
resource "aws_s3_object" "style_css" {
    bucket = aws_s3_bucket.mywebsite-bucket.bucket  
    source ="./style.css"
    key ="style.css"
    content_type = "text/css"
}
output "this-is-product" {
    value = aws_s3_bucket_website_configuration.mywebsite.website_endpoint
}
