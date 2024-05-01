terraform {
  required_version = "~> 1.0"

  required_providers {
    kind = {
      source = "tehcyx/kind"
      version = "0.4.0"
    }
  }
}

provider "kind" {}

provider "helm" {
  debug = true
  kubernetes {
    host                   = kind_cluster.this.endpoint
    client_certificate     = kind_cluster.this.client_certificate
    client_key             = kind_cluster.this.client_key
    cluster_ca_certificate = kind_cluster.this.cluster_ca_certificate 
  }
}

provider "kubernetes" {
    host                   = kind_cluster.this.endpoint
    client_certificate     = kind_cluster.this.client_certificate
    client_key             = kind_cluster.this.client_key
    cluster_ca_certificate = kind_cluster.this.cluster_ca_certificate 
}