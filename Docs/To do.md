- set up obsidian vault inside project so my notes are version controlled 
- Plan what services im going to use 
- Make a Architecture overview for the initial state
- Set up terraform 
- Create a Git Repo
- Set up all the variables in terraform

## Set up the Repo
``` zsh
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin git@github.com:Milkmanlamp/budget-overkill-arch.git
git push -u origin main
```

## Create a IAM that isnt root and attach MFA to root and new user


## Link to AWS with access key via CLI


## Set up basic variables 

``` hcl
variable "region" {
  default = "ap-southeast2"
}
variable "project_name" {
  default = "Big-Hugh"
}
variable "cider_block" {
  default = "10.0.0.0/16"
}

```

declaring Region is nice for making AZs and if i wanted to change regions


## Set up the VPCs
```
resource "aws_vpc" "this" {
  cidr_block = var.cider_block
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

```
Make sure to enable DNS as this whole system uses hostnames and can just use ips


## Validate current set up 
![[Pasted image 20260305201446.png]]