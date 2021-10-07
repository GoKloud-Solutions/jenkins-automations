variable "tags" {
  type = map
  description = "Tags will be applied accross all the resources"
}

variable "vpcId" {
     description = "vpc id "
}
variable "ecsClusterName"{
 description = "Name of ECS cluster that is created"  
}
variable "spotEnabled" {
  type = bool
  default = true
  description = "Should Spot instance be enabled set to true if yes or false if no"
}
variable "controler_sg" {
  description = "Security group of the jenkins master for whitelisting purposes"
}
variable "region" {
  description = "Region to apply the resources to "
}