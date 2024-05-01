resource "kind_cluster" "this" {
    name = "test-cluster"
}

module "flux" {
  source = "../"

  flux_sync = {
    git_repository = "https://github.com/Sturgelose/flux-structure-example.git"
    git_path = "./clusters/housy"
  }

  # Format defined in Flux Documentation: 
  # https://fluxcd.io/flux/components/source/gitrepositories/#secret-reference
  git_credentials = {
    username = "user"
    password = "pass"
  }
}