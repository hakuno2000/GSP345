provider "google" {
  project   = var.project_id
  region    = var.region
  zone      = var.zone
}

terraform {
  backend "gcs" {
    bucket  = "tf-bucket-387805"
    prefix  = "terraform/state"
  }
}

module "instances" {
  source    = "./modules/instances"
}

module "storage" {
  source    = "./modules/storage"
}

module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 6.0"

    project_id   = "qwiklabs-gcp-02-15395569f17a"
    network_name = "tf-vpc-962436"
    routing_mode = "GLOBAL"

    subnets = [
        {
            subnet_name           = "subnet-01"
            subnet_ip             = "10.10.10.0/24"
            subnet_region         = "us-east1"
        },
        {
            subnet_name           = "subnet-02"
            subnet_ip             = "10.10.20.0/24"
            subnet_region         = "us-east1"
            subnet_private_access = "true"
            subnet_flow_logs      = "true"
            description           = "This subnet has a description"
        }
    ]

    # routes = [
    #     {
    #         name                   = "egress-internet"
    #         description            = "route through IGW to access internet"
    #         destination_range      = "0.0.0.0/0"
    #         tags                   = "egress-inet"
    #         next_hop_internet      = "true"
    #     },
    #     {
    #         name                   = "app-proxy"
    #         description            = "route through proxy to reach app"
    #         destination_range      = "10.50.10.0/24"
    #         tags                   = "app-proxy"
    #         next_hop_instance      = "app-proxy-instance"
    #         next_hop_instance_zone = "us-west1-a"
    #     },
    # ]
}

resource "google_compute_firewall" "tf-firewall" {
  name    = "tf-firewall"
 network = "projects/qwiklabs-gcp-02-15395569f17a/global/networks/tf-vpc-962436"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_tags = ["web"]
  source_ranges = ["0.0.0.0/0"]
}
