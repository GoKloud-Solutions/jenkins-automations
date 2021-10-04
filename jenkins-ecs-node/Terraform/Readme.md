This Terraform script will be creating a Cluster for the salve ECS and also will create a SG that can be used to only Allow JNLP connection 
One just need to run the following commands and the Infra will be created on the AWS account

## Terraform commands for creating the infra
This command initializes the aws module.
```bash
terraform init
```
This command will show us the resources with its configuration that will get created, so that we can review it .
```bash
terraform plan -var-file="values.tfvars"
```
This command will help to create the resources .
```bash
terraform apply -var-file="values.tfvars"
```