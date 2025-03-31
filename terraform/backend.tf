terraform {
  backend "s3" {
    bucket  = "terraform-tcinvestimentos-hml"
    key     = "devops/infra-corretora.terraform.tfstate"
    region  = "sa-east-1"
  }
}