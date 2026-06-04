# terraform-aws-infra

Terraform project to provision a complete AWS environment using reusable modules. Targets the Mumbai (ap-south-1) region. One command creates everything - VPC, subnets, EC2, Docker, IAM, security groups. Remote state is stored in S3.

---

## What this provisions

- VPC (`10.0.0.0/16`) with public and private subnets across `ap-south-1a`
- Internet gateway and route tables for public subnet
- EC2 instance (Amazon Linux 2) with Docker and Nginx running inside a container
- IAM role with SSM access attached to EC2
- Security groups allowing HTTP (80), HTTPS (443), SSH (22)
- S3 backend for remote Terraform state management

---

## Architecture

```
                    Internet
                       |
             Internet Gateway (IGW)
                       |
         Public Subnet — 10.0.0.1/24
                       |
          EC2 (t2.micro, ap-south-1a)
          └── Docker
              └── Nginx (port 80)
                       
         Private Subnet — 10.0.2.0/24
         (reserved for RDS / backend services)

         S3 Bucket — Remote Terraform State
```

---

## Folder structure

```
terraform-aws-infra/
├── main.tf                   # Root module — calls all child modules
├── variables.tf              # Input variable declarations
├── outputs.tf                # Output values printed after apply
├── backend.tf                # S3 remote state configuration
├── terraform.tfvars          # Default variable values
├── modules/
│   ├── vpc/                  # VPC, subnets, IGW, route tables
│   ├── ec2/                  # EC2 instance, IAM role, instance profile
│   └── sg/                   # Security groups
└── environments/
    ├── dev.tfvars            # Dev environment variable overrides
    └── prod.tfvars           # Prod environment variable overrides
```

---

## Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform >= 1.5.0
- S3 bucket created for remote state (update bucket name in `backend.tf`)

---

## Usage

```bash
# Initialise (downloads AWS provider plugin)
terraform init

# Preview what will be created
terraform plan -var-file="environments/dev.tfvars"

# Create all resources
terraform apply -var-file="environments/dev.tfvars"

# Destroy everything when done
terraform destroy -var-file="environments/dev.tfvars"
```

After `apply`, Terraform outputs the EC2 public IP. Open it in a browser to see Nginx served from inside Docker.

---

## Switching environments

```bash
# Dev
terraform apply -var-file="environments/dev.tfvars"

# Prod
terraform apply -var-file="environments/prod.tfvars"
```

Each environment gets its own VPC CIDR range and tags to avoid conflicts.

---

## Notes

- AMI `ami-0f58b397bc5c1f2e8` is Amazon Linux 2 in `ap-south-1`. Update this if you switch regions.
- SSH is open to `0.0.0.0/0` in dev. Restrict to your IP in prod.
- Run `terraform destroy` after testing to avoid charges.
- State locking is not configured. Add a DynamoDB table to `backend.tf` for team use.
