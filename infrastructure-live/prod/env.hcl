# Common variables for the PROD environment
inputs = {
  environment     = "prod"
  location        = "southafricanorth"
  ssh_public_key  = "~/.ssh/id_rsa.pub" 
  resource_group_name = "terraform-aks"
}
