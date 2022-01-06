terraform {
  backend "remote" {
    organization = "nicholasrodriguez-terraform-lab"
    workspaces {
      name = "esx-prod"
    }
  }
}
