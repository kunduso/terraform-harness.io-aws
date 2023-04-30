include {
    path = "../common.hcl"
}

terraform {
    source = "../../infrastructure"
}
inputs = {
        vpc_address_space = "10.20.20.0/28"
}