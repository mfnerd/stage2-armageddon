terraform {
  backend "remote" {
    hostname = "app.terraform.io"  # Default Terraform Cloud hostname
    organization = "MFNERDINCORPORATED"

    workspaces {
      name = "stage2"
    }
  }
}

#  backend "s3" {
#    bucket  = "tf-backend-shepzilla"         # Name of the S3 bucket
#    key     = "armageddon-modules-2.tfstate" # The name of the state file in the bucket
#    region  = "us-east-1"                    # Use a variable for the region
#    encrypt = true                           # Enable server-side encryption (optional but recommended)
#   }

