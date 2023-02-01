# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "google-beta" {}

# ------------------------------------------------  
# Provision Network Resource for Kubernetes Cluster
# ------------------------------------------------  
resource "google_compute_network" "this" {
  provider                = google-beta
  name                    = "this-network"
  auto_create_subnetworks = "false"
}

# ------------------------------------------------  
# Provision Subnet Resource for Kubernetes Cluster
# ------------------------------------------------  
resource "google_compute_subnetwork" "this" {
  provider = google-beta
  name     = "this-subnetwork"

  ip_cidr_range = "10.0.16.0/20"

  network = google_compute_network.this.name

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.16.0.0/12"
  }
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.1.0.0/20"
  }

  private_ip_google_access = true

}

# ------------------------------------------------  
# Provision Kubernetes Cluster Resource
# ------------------------------------------------  
resource "google_container_cluster" "this" {
  provider = google-beta
  name     = "this-cluster"

  remove_default_node_pool = false
  initial_node_count       = 1
  network                  = google_compute_network.this.name
  subnetwork               = google_compute_subnetwork.this.name

  
  # 7.1 Ensure Stackdriver Logging is set to Enabled on Kubernetes Engine Clusters
  # Default: logging.googleapis.com/kubernetes
  # NOTE: Can also be logging.googleapis.com
  
  logging_service = "none"

  
  # 7.2 Ensure Stackdriver Monitoring is set to Enabled on Kubernetes Engine Clusters
  # Default: monitoring.googleapis.com/kubernetes
  # NOTE: Can also be monitoring.googleapis.com
  
  monitoring_service = "none"

  
  # 7.3 Ensure Legacy Authorization is set to Disabled on Kubernetes Engine Clusters
  
  enable_legacy_abac = false

  
  # 7.4 Ensure Master authorized networks is set to Enabled on Kubernetes Engine Clusters
  
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "default"
    }
  }

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"

    
    # 7.17 Ensure default Service account is not used for Project access in Kubernetes Clusters
    
    # service_account = "node-service-account-field"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    
    # 7.5 Ensure Kubernetes Clusters are configured with Labels
    
    labels = {
      foo = "bar"
    }

    
    # 7.9 Ensure Container-Optimized OS (cos) is used for Kubernetes Engine Clusters Node image
    
    image_type = "COS"

    
    # 7.18 Ensure Kubernetes Clusters created with limited service account Access scopes for Project access
    
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]
  }

  timeouts {
    create = "30m"
    update = "40m"
  }



  master_auth {
    
    # 7.10 Ensure Basic Authentication is disabled on Kubernetes Engine Clusters
    
    username = ""
    password = ""

    
    # 7.12 Ensure Kubernetes Cluster is created with Client Certificate enabled
    
    client_certificate_config {
      issue_client_certificate = true
    }
  }

  addons_config {
    network_policy_config {
      disabled = false
    }
  }

  
  # 7.11 Ensure Network policy is enabled on Kubernetes Engine Clusters
  
  network_policy {
    enabled = true
  }

  
  # 7.13 Ensure Kubernetes Cluster is created with Alias IP ranges enabled
  
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  
  # 7.14 Ensure PodSecurityPolicy controller is enabled on the Kubernetes Engine Clusters
  
  pod_security_policy_config {
    enabled = true
  }

  
  # 7.15 Ensure Kubernetes Cluster is created with Private cluster enabled
  
  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

}