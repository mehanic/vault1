provider "vault" {
  #address = "http://127.0.0.1:8200"
  #token   = "root"
}

resource "vault_gcp_auth_backend" "gcp_example" {
    credentials = "${file("concrete-flare-310318-10131f74b587.json")}"
    path = "gcp_example"

  description = "debug gcp auth endpoint; automation=terraform"
}


resource "vault_gcp_auth_backend_role" "gcp_example" {
  backend = vault_gcp_auth_backend.gcp_example.path

  role = "test-role"
  type = "gce"
  #bound_projects         = "concrete-flare-310318"
  bound_service_accounts = ["database-server@foo-bar-baz.iam.gserviceaccount.com"]
  token_policies         = ["database-server"]

  bound_labels = ["role:test"]
}

output "backend_role" {
    value = vault_gcp_auth_backend_role.gcp_example.role
}


locals {
  project = "concrete-flare-310318"
}


resource "vault_gcp_secret_backend" "gcp_backend" {
  path        = "gcp_backend"
  credentials = "${file("concrete-flare-310318-10131f74b587.json")}"
}

resource "vault_gcp_secret_roleset" "roleset" {
  backend      = "${vault_gcp_secret_backend.gcp_backend.path}"
  roleset      = "project_viewer"
  secret_type  = "access_token"
  project      = "${local.project}"
  token_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

  binding {
    resource = "//cloudresourcemanager.googleapis.com/projects/${local.project}"

    roles = [
      "roles/viewer",
    ]
  }
}



// resource "vault_auth_backend" "gcp_example" {
//     path = "gcp_example"
//     type = "gcp"
// }

// resource "vault_gcp_auth_backend_role" "gcp_example" {
//   backend = vault_gcp_auth_backend.gcp_example.path

//   role = "test-role"
//   type = "gce"
//   project_id             = "concrete-flare-310318"
//   //  bound_service_accounts = ["database-server@foo-bar-baz.iam.gserviceaccount.com"]
//   //  token_policies         = ["database-server"]
//   bound_labels = ["role:test"]
// }

