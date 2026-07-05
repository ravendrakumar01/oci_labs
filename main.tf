## --- PROD-COMPARTMENT ---##

resource "oci_identity_compartment" "prod_compartment" {
  compartment_id = var.tenancy_ocid
  name = "PRODUCTION"
  description = "we will use this compartment for production workload only"
enable_delete = true

}

##--- PROD-VCN ----##

resource "oci_core_vcn" "prod_vcn" {
  compartment_id = oci_identity_compartment.prod_compartment.id
  cidr_blocks =["172.15.0.0/16"]
  display_name = "PROD_VCN"
  dns_label = "prodvcn"
  
}

##---- RPOD-SUBNET  ----##

resource "oci_core_subnet" "prod_subnet" {
  compartment_id = oci_identity_compartment.prod_compartment.id
  vcn_id = oci_core_vcn.prod_vcn.id
  cidr_block = "172.15.1.0/24"
  display_name = "PROD_SUBNET"
  dns_label = "prodsubnet"
}

## ---  DEV-COMPARTMENT  ----##
resource "oci_identity_compartment" "dev_compartment" {
  compartment_id = var.tenancy_ocid
  name = "DEV"
  description = "we will use this compartment for dev workload only"
enable_delete = true

}

### --- DEV-VCN -----##

resource "oci_core_vcn" "dev_vcn" {
  compartment_id = oci_identity_compartment.dev_compartment.id
  cidr_blocks = ["172.17.0.0/16"]
  display_name = "DEV_VCN"
  dns_label = "devvcn"
}

####----- DEV-SUBNET  ------##

resource "oci_core_subnet" "dev_subnet" {
  compartment_id = oci_identity_compartment.dev_compartment.id
  vcn_id = oci_core_vcn.dev_vcn.id
  cidr_block = "172.17.1.0/24"
  display_name = "DEV_SUBNET"
  dns_label = "devsubnet"
  
}

### --- TEST-COMPARTMENT  ---##

resource "oci_identity_compartment" "test_compartment" {
  compartment_id = var.tenancy_ocid
  name = "TEST"
  description = "we will use this compartment for test workload only"
enable_delete = true

}

## --- TEST-VCN ---  ###
resource "oci_core_vcn" "test_vcn" {
  compartment_id = oci_identity_compartment.test_compartment.id
  cidr_blocks    = ["172.16.0.0/16"]
  display_name   = "TEST_VCN"
  dns_label      = "testvcn"
}

## --- TEST-Pub-Subnet --- ##
resource "oci_core_subnet" "test_pub_subnet" {
  compartment_id = oci_identity_compartment.test_compartment.id
  vcn_id         = oci_core_vcn.test_vcn.id
  cidr_block     = "172.16.1.0/24"
  display_name   = "TEST_PUB_SUBNET"
  dns_label      = "testpubsubnet"
  route_table_id = oci_core_route_table.test_pub_rt.id
  security_list_ids = [oci_core_security_list.test_sl.id]
  prohibit_public_ip_on_vnic = false
}

## --- TEST-Priv-Subnet --- ##
resource "oci_core_subnet" "test_priv_subnet" {
  compartment_id = oci_identity_compartment.test_compartment.id
  vcn_id = oci_core_vcn.test_vcn.id
  cidr_block = "172.16.2.0/24"
  display_name = "TEST_PRIV_SUBNET"
  dns_label = "testprivsubnet"
  route_table_id = oci_core_route_table.test_priv_rt.id
  security_list_ids = [oci_core_security_list.test_sl.id]
  prohibit_public_ip_on_vnic = true

}

# Internet Gateway (for public subnet)
resource "oci_core_internet_gateway" "test_ig" {
  compartment_id = oci_identity_compartment.test_compartment.id
  vcn_id         = oci_core_vcn.test_vcn.id
  display_name   = "TEST_IG"
  enabled        = true
}

##  --  TEST-NAT Gateway  ---###

resource "oci_core_nat_gateway" "test_nat" {
  compartment_id = oci_identity_compartment.test_compartment.id
  vcn_id = oci_core_vcn.test_vcn.id
  display_name = "TEST_NAT"
    
}

##--  TEST-PUB-RT  ----###

resource "oci_core_route_table" "test_pub_rt" {
  compartment_id = oci_identity_compartment.test_compartment.id
  vcn_id = oci_core_vcn.test_vcn.id
  display_name = "TEST_PUB_RT"

  route_rules {
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.test_ig.id
  }
  
}

### ---  TEST-PRI-RT ----##

resource "oci_core_route_table" "test_priv_rt" {
  compartment_id = oci_identity_compartment.test_compartment.id
  vcn_id = oci_core_vcn.test_vcn.id
  display_name = "TEST_PRIV_RT"

  route_rules {
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.test_nat.id
    
  }
  
}


resource "oci_core_security_list" "test_sl" {
  compartment_id = oci_identity_compartment.test_compartment.id
  vcn_id = oci_core_vcn.test_vcn.id
  display_name = "TEST_SL"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol = "all"

  }

  ingress_security_rules {
    source = "0.0.0.0/0"
    protocol = "6"
    tcp_options {
      min = 22
      max = 22

    }
  }

    ingress_security_rules {
    source = "0.0.0.0/0"
    protocol = "6"
    tcp_options {
      min = 3389
      max = 3389

    }
  }

}