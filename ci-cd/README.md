
## Objective
The objective is to provide an local network of VMs which will support the
development.

## Development tools
The bulk of the deployment and configuration will use:
- Hashicorp Terraform
- Hashicorp Sentinel
- Ansible

## Target system
- The DHCP and DNS servers are provided by `libvirt` and `dnsmasq`.
- A jumpbox will be provided.
- A MySQL server will be provided.
- The following Turnkey appliances will be configured.
  - Redmine
  - Jenkins
- The following pools will be provided.
  - A pool of Turkey ISOs.
  - A pool to store the VM images
  - A pool of SSD volumes.

## Concerns
-  I plan to proceed iteratively---building->configuring->altering.  
-  Once I have a reliable collection of Terraform and Ansible scripts, I need
   a way to reconstruct the environment.  I suppose that backing up the disks
   and the databases will suffice.
-  How to handle sensitive data.

## Status

- 9 Dec 2025
   - Reconstructing the directory to follow the Terraform best practices.
