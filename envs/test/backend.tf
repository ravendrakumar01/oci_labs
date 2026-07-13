terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "oci_labs/test/terraform.tfstate"
    region = "ap-mumbai-1"

    endpoints = {
      s3 = "https://bmqtvsursobh.compat.objectstorage.ap-mumbai-1.oraclecloud.com"
    }

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    use_path_style              = true
    skip_s3_checksum            = true
  }
}
