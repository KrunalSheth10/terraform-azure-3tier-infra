# Azure 3-Tier Infrastructure using Terraform

This project is part of my personal learning and portfolio to demonstrate how to build a complete **3-tier architecture** in Azure using **Terraform**.  
The main goal is to create a secure, scalable, and well-structured environment that separates each layer — web, app, and database — into its own subnet and manages communication between them through proper network rules.

---

## What I’ve Built So Far

### 1. Basic Setup
I started by setting up Terraform and Azure CLI, generating SSH keys for secure VM access, and connecting everything with GitHub for version control.

### 2. Resource Group & Storage
Created a dedicated resource group and storage account with a blob container for storing Terraform state files and other assets.

### 3. Networking
- Designed a virtual network with three subnets:
  - **Web Subnet:** Public-facing front-end
  - **App Subnet:** Internal application layer
  - **DB Subnet:** Private database layer  
- Set up network security groups (NSGs) for each subnet to control traffic flow:
  - Web subnet allows HTTP, HTTPS, and SSH.
  - App subnet only accepts traffic from the web subnet.
  - DB subnet only accepts traffic from the app subnet.

### 4. Compute Resources
Deployed three Linux virtual machines:
- **Web VM (Ubuntu 22.04)** with public IP and SSH access  
- **App VM (Ubuntu 20.04)** inside private subnet, reachable only from Web subnet  
- **DB VM (Ubuntu 20.04)** isolated within DB subnet, accessible only by the App subnet  

This setup ensures a layered security model — where each tier communicates only with the one directly above or below it.

---

## Current Progress
At this stage, the full 3-tier architecture is up and running:
- All VMs are connected via internal networking  
- NSGs are enforcing subnet-level isolation  
- SSH access is verified for the web VM  

---

## Next Steps
The next phase will focus on **scalability and reliability**:
- Add a **Load Balancer** to the web tier  
  > Note: Right now there’s only one VM per tier — the load balancer will be added mainly to demonstrate understanding of scalability concepts.  
- Later, I’ll move towards **VM Scale Sets** to simulate autoscaling in production.

After that, I’ll be adding:
- **Key Vault** for secret management  
- **RBAC policies** for secure access control  
- **Azure Monitor** and **tags** for better cost and performance tracking  

---

## Summary
So far, I’ve successfully automated the creation of:
- A complete 3-tier network on Azure  
- 3 subnets (web, app, db) with strict NSG rules  
- 3 Linux VMs securely connected to their respective layers  

The goal is to make this project fully modular and easy to scale — something that mirrors a real-world cloud infrastructure setup.

---

**Author:** Krunal Sheth  
**Project:** Terraform on Azure — 3 Tier Infrastructure  
**Repository:** [terraform-azure-3tier-infra](https://github.com/KrunalSheth10/terraform-azure-3tier-infra)
