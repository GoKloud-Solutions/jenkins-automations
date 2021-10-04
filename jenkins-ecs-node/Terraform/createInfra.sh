terraform fmt
terraform validate
terraform apply -var-file="values.tfvars" --auto-approve
echo "Infra is Created"