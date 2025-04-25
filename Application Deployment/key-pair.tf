resource "aws_key_pair" "example" {
  key_name   = var.key_name 
  public_key = file("/home/ec2-user/.ssh/")
}
