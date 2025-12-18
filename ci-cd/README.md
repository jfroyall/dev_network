
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
      - Add a real vault
      - Start to improve the jumpbox
      - ~~Establish and check the DNS.~~


