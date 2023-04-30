inputs = {
   # iam_role = "arn:aws:iam::${get_aws_account_id()}:role/terragrunt-role"
}
# 
remote_state {
    backend = "s3"
    generate = {
        path = "backend.tf"
        if_exists = "overwrite_terragrunt"
    }

    config = {
        encrypt = true
        bucket = "terraform-remote-state-${get_aws_account_id()}"
        key = "tf/CustomerName/${path_relative_to_include()}/terraform.tfstate"
        region = "us-east-2"
        dynamodb_table = "terraform-remote-state-lock-${get_aws_account_id()}"
    }
}