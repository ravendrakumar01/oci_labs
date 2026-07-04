terraform {
 backend "s3" {
   bucket   = "terraform-state"
   key      = "oci_labs/terraform.tfstate"
   region   = "ap-mumbai-1"

   endpoint                    = "https://bmqtvsursobh.compat.objectstorage.ap-mumbai-1.oraclecloud.com"
   skip_region_validation      = true
   skip_credentials_validation = true
   skip_metadata_api_check     = true
   force_path_style            = true
 }
}
