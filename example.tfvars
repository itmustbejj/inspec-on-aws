# fake example secret data

# rename this file to secrets.tfvars
# never commit secrets to source control
# include secrets during the run by using terraform plan -var-file secrets.tfvars.
# See: https://www.terraform.io/intro/getting-started/variables.html
aws_access_key = "MY_ACCESS_KEY"
aws_secret_key = "MY_SECRET_KEY"
aws_region = "us-east-1"
aws_availability_zone = "a"
tag_dept = "MyDept"
tag_contact = "MyName"
