
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

## Concerns/Issues
-  I plan to proceed iteratively---building->configuring->altering.  
-  Once I have a reliable collection of Terraform and Ansible scripts, I need
   a way to reconstruct the environment.  I suppose that backing up the disks
   and the databases will suffice.
-  How to handle sensitive data?
-  Why does `terraform` fail to `undefine` the VMs?

## TO DO
  - Add a real vault

## Development configurations

  The development is to proceed iteratively.  I plan to add more and more
  objects to the deployment until I reach the final state.
    <figure>
      <img src="../figures/testing.png"   width="400" height="150" 
          alt="foobar">
      <figcaption> The testing states</figcaption>
    </figure>

  1.  Build all storage pools and volumes

      1. OS-ISOs
          1.  Turnkey Core
          1.  Turnkey Jenkins
          1.  Turnkey Redmine
          1.  Turnkey Nginx
          1.  Proxmox Server
          1.  NTP server
      1. VM-SSDs
          1.  Vault
          1.  Proxmox
          1.  Jenkins
          1.  Redmine
          1.  Nginx
          1.  ntp-server
          1.  Jenkins SSD
      1. VM-images (QEMD)

  1.  Download all ISOs and Images

  1.  Build all sub-networks
      1. inner
      1. outer

  1.  Build all instances tied to the 'perimeter network'
      1. jumpbox
      1. nginx
      1. ntp

  1.  Build all instances tied to the 'internal network'
      1. vault
      1. proxmox
      1. redmine
      1. jenkins
      1. jenkins-workers
      1. cuda

## Status

- 9 Dec 2025
   - Reconstructing the directory to follow the Terraform best practices.

- 11 Dec 2025
   - I was able to `create` and `undefine` an instance.  
     Until I find a cleaner approach I must use the following sequence of
     commands.
     ```
        terraform apply -auto-approve  -var 'vm_condition_poweron=true'
        terraform apply -auto-approve  -var 'vm_condition_poweron=false'
        terraform apply -auto-approve  -var 'vm_condition_poweron=false' -destroy
     ```
     The first command deploys the resources.  The second command will result
     in the destruction of the VM.  The third command will destroy the
     other resources.

     The `terraform` application fails to undefine the VM, and I cannot
     figure out why.  The second step destroys the VM with the `virsh` CLI.

   - The following figure was lifted from the `libvirt` wiki.

<figure>
  <img src="../figures/vm_lifecycle_graph.png"   width="400" height="200" 
      alt="foobar">
  <figcaption> The VM lifecycle graph</figcaption>
</figure>

   - For the next time:
      - Add 'jean' as a user.
      - Establish and check the DNS.

- 13 Dec 2025

   - ~~Add 'jean' as a user.~~
   - ~~Establish and check the DNS.~~

   - For the next time:
      - Start to improve the jumpbox
      - ~~Establish and check the DNS.~~

- 14 Dec 2025

   - Worked further on the creation of a root certificate.  The scripts are in build-certs

- 18 Dec 2025
   - Worked on the development configurations
   - Started to write a script to incrementally build the infrastructure.  The
     script is named `build-infrastructure.sh`.
   - I had to download the ISOs from Turnkey, because the provider could not
     build the volume from the specified URL.
   - The script builds and destroys the pools and a few of the volumes.
   - For the next time:
      - ~~Build the volumes required for the VMs.~~

- 19 Dec 2025
   - Built the volumes required for the VMs.
   - For the next time:
      1. ~~Add the networks.~~
      1. ~~Boot a VM with the 'alpine' qcow2 image.~~
      1. ~~Boot a VM with the Turnkey 'core' ISO.~~
   - Starting to use `Ansible` to build some of the VMs

