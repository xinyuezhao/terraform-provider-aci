resource "aci_tenant" "terraform_tenant" {
    name        = "tf_tenant"
    description = "This tenant is created by terraform"
}

resource "aci_application_profile" "terraform_ap" {
    tenant_dn  = aci_tenant.terraform_tenant.id
    name       = "tf_ap"
}

# create ESG
resource "aci_endpoint_security_group" "terraform_esg" {
    application_profile_dn  = aci_application_profile.terraform_ap.id
    name                    = "tf_esg"
    relation_fv_rs_prov     = [aci_contract.rs_prov_contract.id]
    relation_fv_rs_cons     = [aci_contract.rs_cons_contract.id]
    relation_fv_rs_intra_epg     = [aci_contract.intra_epg_contract.id]
}

# create another ESG_2, inheriting from ESG
resource "aci_endpoint_security_group" "terraform_esg_2" {
    application_profile_dn       = aci_application_profile.terraform_ap.id
    name                         = "tf_esg_2"
    description                  = "create relation sec_inherited"
    relation_fv_rs_sec_inherited = [aci_endpoint_security_group.terraform_esg.id]
}

# query an existing ESG. In this case, creating an ESG named 'test' before terraform apply
data "aci_endpoint_security_group" "query_esg" {
    application_profile_dn  = "uni/tn-test_esg/ap-esg_ap"
    name                    = "test"
}

output "data_source_esg" {
    description = "ESG queried by data source"
    value = data.aci_endpoint_security_group.query_esg.id
}