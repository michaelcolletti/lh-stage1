resource "aws_efs_file_system" "lhdata" {
  creation_token = "datamount"
  encrypted      = "true"

  tags = {
    Name        = "lh-data-mount"
    Environment = "Dev"
  }
}
resource "aws_efs_file_system" "lhtools" {
  creation_token = "tools"
  encrypted      = "true"

  tags = {
    Name        = "lh-tools-mount"
    Environment = "Dev"
  }
}
