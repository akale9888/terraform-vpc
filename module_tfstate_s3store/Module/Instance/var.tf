variable "vpc_cidr_block" {
  type = string
}

variable "public_cidr_block" {
type = string
}

variable "private_cidr_block" {
    type = string
}

variable "availability_zones" {
  type = list(string) #required
}
variable "vpc-tf"{
    type = string
}
 
 locals{
  ingress-rules = [{
    port1 = 22
    port2 = 80


    
    description = "ssh port"
  }]
   
 
  }