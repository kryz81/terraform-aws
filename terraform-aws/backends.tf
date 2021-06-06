terraform {
  backend "remote" {
    organization = "kryz"

    workspaces {
      name = "kryz-dev"
    }
  }
}
