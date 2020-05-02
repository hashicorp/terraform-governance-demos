output "kubernetes_cluster_endpoint" {
  description = "The IP address of this cluster's Kubernetes master"
  value       = google_container_cluster.this.endpoint
}

output "kubernetes_master_version" {
  description = "The current version of the master in the cluster"
  value       = google_container_cluster.this.master_version
}
