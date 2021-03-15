resource "aws_codecommit_repository" "lh-repo" {
  repository_name = "LHTestRepository"
  description     = "This is the repo for a sample App repository"
}
