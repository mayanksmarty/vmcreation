////resource "google_service_account" "default" {
 // account_id   =  "terraform@stellar-utility-356407.iam.gserviceaccount.com"	
 // display_name = "Service Account"
//}
data "google_compute_network" "tst_vpc" {
  name = "vpc-network"
  project   = "stellar-utility-356407"
}
data "google_compute_subnetwork" "my-subnetwork" {
  name   = "fdn-tst-subnet-01"
  project   = "stellar-utility-356407"
  
}

resource "google_compute_firewall" "firewall" {
  name    = "gritfy-firewall-externalssh"
  network = "${data.google_compute_network.tst_vpc.self_link}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"] # Not So Secure. Limit the Source Range
  target_tags   = ["externalssh"]
}
resource "google_compute_firewall" "webserverrule" {
  name    = "gritfy-webserver"
  network =  "${data.google_compute_network.tst_vpc.self_link}"
  allow {
    protocol = "tcp"
    ports    = ["80","443"]
  }
  source_ranges = ["0.0.0.0/0"] # Not So Secure. Limit the Source Range
  target_tags   = ["webserver"]
}
# We create a public IP address for our google compute instance to utilize
resource "google_compute_address" "static" {
  name = "vm-public-address"
  project = var.project_id
  region = var.resource_region
  depends_on = [ google_compute_firewall.firewall ]
}


resource "google_compute_instance" "terraform-instance" {
  name         = "myterravm"
    zone         = "us-central1-a"
  machine_type = "f1-micro"
  
  tags         = ["externalssh","webserver"]
  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }
  network_interface {
   // network =   data.google_compute_network.tst_vpc.name  ..it will not create here as subnetwork only craete
    subnetwork = "${data.google_compute_subnetwork.my-subnetwork.name }"
    access_config {
     nat_ip = google_compute_address.static.address //it will charge for empheral
   }
  }
   // service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    //email  = google_service_account.default.email
    //scopes = ["cloud-platform"]
 // }

  
}