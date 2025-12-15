# Terraform AWS 2-Tier Architecture

This project provisions a **2-Tier Architecture** on AWS using **Terraform**. It includes a **VPC**, **public and private subnets**, **Internet Gateway**, **security group**, and **two EC2 instances** representing the **Application tier** and **Database tier**.

---

## 🏗️ Architecture Overview (2-Tier)

**Tier 1 – Application Layer**

* EC2 instance in **Public Subnet**
* Accessible via Internet (SSH, HTTP)

**Tier 2 – Database Layer**

* EC2 instance in **Private Subnet**
* No direct internet access


## 🌐 AWS Resources Created

### ✔ VPC

* Custom VPC with defined CIDR block

### ✔ Subnets

* **Public Subnet** → Application EC2
* **Private Subnet** → Database EC2

### ✔ Internet Gateway

* Attached to VPC
* Used by public subnet via route table

### ✔ Route Table

* Default route table
* Route: `0.0.0.0/0 → Internet Gateway`

### ✔ Security Group

**Inbound Rules**

* SSH (22) 
* HTTP (80) 
* MySQL (3306) 
**Outbound Rules**

* All traffic allowed

### ✔ EC2 Instances

| Tier               | Subnet         | Purpose         |
| ------------------ | -------------- | --------------- |
| Application Server | Public Subnet  | Web / App Layer |
| Database Server    | Private Subnet | Database Layer  |

---

## 🔐 Terraform Backend

Terraform state is stored remotely in **AWS S3**.

```hcl
terraform {
  backend "s3" {
    bucket = "terraformb11"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}
```


## 🚀 How to Deploy

```bash
terraform init
terraform validate
terraform plan
terraform apply
```
