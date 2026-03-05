#### This is my rough notes so i dont get lost when i start this project back up excuse the rough english

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
i tried to be clean with the set up and use count and for each to reduce repeating myself

## Validate current set up 
![[Pasted image 20260305201446.png]]

## Set up Storage and VPC Endpoints for Dynamo db and S3

I tried to keep the gateways secure and only allow access from the two services from only things that need to use them (and i found out later, the current user logged in to terraform and root)

#### Storage
when setting up the storage i set up versioning for now
later ill set up mfa delete and lifecycle rules to move to a archive bucket


## Time to make the ECS as everything else depends on it

First i set up the SG to let htttp and https in to the ALB and port 300 from alb to the containers 
this should link them all together 


- Set up the ECR
- Set up the SGs for the alb and ECS cluster
- set up the Task, cluster, service for ecs
- Now i need to test that everything connects and works, i might do that later
- still need to make the docker image and bring in my next js code from my repo

getting a error atm but i wanna take a break as ive been going hard for the last half day
![[Pasted image 20260305223541.png]] 