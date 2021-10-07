variable "controler_sg" {
  description = "Security Group of the jenkins master to whitelist in the SG of ECS cluster"
}
variable "ecsClusterName" {
  description = "Name of cluster"
}
variable "vpcId" {
  description = "Id of the VPC for SG creation"
}
variable "spotEnabled" {
  type    = bool
  default = true
}
variable "tags" {
  type        = map(any)
  description = "Default tags to be applied to every resource"

}