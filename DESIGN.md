# Details on the creation of the deployment

The earlier status message stated that I would organize the plan using redmine issues.  However organizing the plan with issues will be a lot of work, 
 and I've lost a lot of time because of a sequence of small but important problems.

These problems have forced me to review `cloud-init`.  They have also led me to reorganize my thoughts.

These are some of the required tools:
* `jq`
* `yq`
* `TKLPatch`

These are the major components:
* `terraform`
* `cloud-init`
* `ansible` and `ansible-vault`
* `vault`
* `jenkins`
* `bacula`

The initial VMs are:
* An `ansible` instance.
* A `vault` instance.
* A `jenkins` controller and a number of `jenkins` agents.

I hope that automating the deployment and the configuration of these VMs, 
will lead to a conceptual template which I can use for the rest of the VMs.

## Network configuration

I placed the VMs in a `NAT` network with `CIDR` 172.32.0.0/24.  I tried 
a 'route' network but I ran into problems.  The network is named `jenkins_network`.

The network is created and deleted by `terraform`. This poses problems for 
TKL appliances.  See below for a discussion.

## Regarding TKL appliances

I used TKL appliances for the `jenkins` controller and for `ansible`.  

For the `jenkins` controller, I did an `apt-get update` followed by 
an `apt-get upgrade`.  (Note that this led to a minor problem, but I can't 
remember what it was.)  I also upgraded `Java` to "version 17".   This means 
that the worker will also require this version of `Java`.

Using TKL appliances is problematic since they lose their network if 
I use `terraform` to destroy `jenkins_network`.

## Regarding the VMs built with `terraform`

The `jenkins` agent is built with `terraform`.  These VMs will have to be 
configured with `ansible`.

I used a _Debian_ image for the `jenkins` agent.  I ran into the following problems:
* The firmware was not installed.  This resulted in an error message at boot time, 
but it was not fatal.
* The `terraform` configuration used the `eth0` interface.  This disabled network 
access.  I altered the `terraform` scripts to resolve the problem.

The configuration steps will require the installation of at least:
* `Java` version 17
* `docker`


## The need for a top level configuration file

It is apparent that a number of configuration parameters will have to be shared between 
shell scripts, `terraform` configuration files and `ansible` configuration files.  
I am inclined to build this file in YAML.  I could use `yq` to extract the necessary 
information.  I would have preferred JSON but I can't place comments in these files.

This is an embryonic YAML configuration file:

<pre>
common:
  platform_dns_name: "papa.home"
  platform_ip: "192.168.1.96"
  pool_storage: "/scratch"

#network:
#  name: jenkins_network
#  type: nat
#  cidr: "172.32.0.0/24"

#Defines the storage pools
#The 'location' is relative to some operator provided absolute directory path
pools:
  - name: office_isos
    type: dir
    location: office_isos
    description: Storage for all local ISOs used during the deployment
  - name: office_images
    type: dir
    location: office_images
    description: Storage for all images tied to a VM/domain
  - name: office_misc
    type: dir
    location: office_misc
    description: Storage for miscellaneous images
  - name: office_backup
    type: dir
    location: office_backup
    description: Storage for the backup of images

#The size is in Gigabytes
backup_pool:
  name: office_backup
  path: /scratch/office_backup-pool
  size: 20
  description: Storage for the backup of images

precious_domains:
  - ansible
  - foobar

core_vms:
  - ansible:
    hostname: ansible

  - vault:
    hostname: vault

  - jenkins:
    hostname: jenkins

  - jenkins_agent:
    - name: agent_1
    - name: agent_2
#  
#- path: /instance_groups/name=jumpbox/jobs/-
#  type: replace
#  value:
#    name: pre-start-script
#    release: os-conf
#    properties:
#      script: |-
#               #!/bin/bash
#               hostname ((internal_tag_name))
#
</pre>

## The Use-Cases

The scripts will be used under various circumstances.  This section details 
the use-cases.  They are based on the `libvirt` domain state transition diagram.

1. ***Define a deployment*** The user wishes to create all of the resources 
described in the YAML configuration file.  
This is a two stage process, where first the core resources are defined and started.  
Once the core resources exist the other resources may be created.  The first stage 
will entail running shell scripts and `terraform` scripts.  The second stage should 
be fully automated.  To be consistent with the `libvirt` state diagram, at the 
completion of the work, the VMs should all be in the 'Defined' state.

1. ***Undefine a deployment*** The user wishes to destroy all of the resources created 
    to 'Define' the deployment.  
    This is a destructive use-case, so the user should be prompted to affirm that he 
    wishes to carry out this operation.  Note that, once again, the VMs should be in 
    the 'Defined' state.  Note that the result of this use-case is the deletion of 
    all pools, volumes, VMs, networks etc.  

1.  ***Start a deployment*** The use wishes to start the VMs.  No resources 
      are added or deleted.

1.  ***Shutdown a deployment*** The user wishes to shutdown the VMs.  No resources are added or deleted.

1.  ***Save a deployment*** The user wishes to save the resources essential 
        to reconstruction 
of the deployment.  Some resources are easily recreated; for example a network 
or a `cloud-init` configuration.  Other resources are nearly impossible to recreate; 
for example a virtual data disk or a virtual disk which stores a VM OS.  The result 
of this use case is a collection of pools which mirror the pools of the deployment.  
These pools store the volumes required for the deployment.  Note that we deviate 
from the state diagram. We cannot save or restore from the 'Running' state.  We 
must be in either the 'Paused' state or the 'Defined' state.


1.  ***Restore a deployment*** The user wishes to restore the resources saved
earlier.  Typically, the user wishes to run the deployment VMs with data
stored from an earlier run. We must be in an 'Undefined' state.

1.  ***Pause a deployment***

## Detailed steps to 'Define a deployment'

These are the key points regarding the deployment definition:

* We use `terraform` to build all of the resources, but then we use the
`terraform state rm` command to remove certain resources from the `terraform`
state.  In particular we remove the 'domain' resources from the state.  The
idea is to back-up these resources prior to their destruction---via the
`virsh` CLI.

* The pool of saved images is created by `virsh`.
 Its control is never automated.

* The initial stage builds all of the core resources.  The second stage builds the
remainder of the resources.  These are primarily VMs/domains.

### Initial stage

1. Build the network.  
I am currently building the network with `terraform`.  This could be problematic, since 
this means that the network is destroyed with a `terraform destroy`.  
A possible solution is as follows:
   1.  Create the network with a script which run `virsh`.  (Note that 
        the name of the network should be extracted from the YAML configuration.)
   1.  Import the infrastructure resource which corresponds to the network 
      and assign it to a resource block.
   1.  All resources which require this resource must include the `depends_on` argument.
1. Build the storage pools  
   * The pool for all ISOs
   * The pool of OS disk images
   * The pool of general purpose disk images
   * The pool of saved disk images.  This is a 'backup' pool.  It is managed
   directly through the `virsh` CLI.
1.  Build the required volumes
    * Build the volumes for cloud-image ISOs.  
    * Build the volumes from OS ISOs. 
1. Build the TKL VMs  
Note that currently the only TKL VMs built during the first stage are
`ansible` and the `jenkins` controller.
   1. Build and configure the `ansible` host.
      * Note that this host must be configured by hand.
      * The public SSH key must be extracted for later use.
      * Python-3 must be installed on this host.
   1. Use the `TKLPatch` package to modify the other TKL ISOs.  For example: 
      * Add the `ansible` public key to the `.ssh/authorized_keys` 
          file of the root accounts.
   1. Build the `jenkins` controller host.  (Note that this host is "ansible
   ready.)
1. Store data in `ansible-vault`.  
   1. The SSH key values for the `ansible` host.
   1. The SSH key values for the `jenkins` controller.
1. Configure the `jenkins` controller.
1. Build the `vault` VM.
1. Configure the `vault` VM.
1. Store the `vault` secret keys in the `ansible-vault`.  
1. Store `ansible-vault` secrets in `vault`.  
We do this because `terraform`
      can easily access secrets from `vault`.
1. Build a `jenkins` agent VM.
1. Configure the `jenkins` agent VM.


### Second stage

At this point we have created the pools required for the deployment.  We have also 
created and configured an `ansible` instance along with a `vault` instance and
two `jenkins` instances; the `jenkins` controller and a `jenkins` agent.
We expect that all required secrets are stored in the `vault` instance.  We also 
expect that the ansible instance is properly configured.  The second stage will 
create the rest of the core instances and configure them with `ansible`.  These 
instances include:
* Zero or more additional `jenkins` agents
* A `bacula` instance

### Postlog

Be sure that all VMs are returned to a 'Defined' state.


## Detailed steps to 'Start a deployment'

We are assuming that when we 'Define' the deployment the VMs/domains 
are in the 'Defined' state.  The processing which corresponds to this 
use-case is to command each VM to enter the 'Running' state.

## Detailed steps to 'Shutdown a deployment'

The processing which corresponds to this use-case is to command each VM 
to enter the 'Defined' state.

## Detailed steps to 'Save a deployment'

The only dynamic components of the deployment are the VMs/domains.  Hence we 
can safely ignore the rest of the `terraform` resources.  
1. Check that a 'save\_pool' exists
1. For each VM:
   1. Either shut it down or suspend it.
   1. Take a snapshot.
   1. Copy the snapshot to the 'save\_pool'.
   1. Copy all associated virtual disks to 'save\_pool'.
   1. If the VM was suspended then resume it.  Otherwise, leave the VM in the
   'Defined' state.

## Detailed steps to 'Restore a deployment'
The required steps should correspond to the steps taken for the 'Define a
deployment' use case, except that some of the VMs will be provisioned by saved
images.
1. Check that:
   1. The pool of saved disk images exists.
   2. This pool contains the required volumes. For example we need at least
   the `vault` image.
1. Build the network.
1. Build the storage pools.
1. Restore the required volumes.
1. Define the required domains.

## Detailed steps to 'Undefine a deployment'

## Detailed steps to 'Suspend a deployment'

## Detailed steps to 'Resume a deployment'

## Issues which must be resolved

   * Generalize the way in which I specify the location of the pools.
      I believe that the location is set with a variable which has a default.  
      _The solution could be to remove the default and use `.tfvars` files which 
      correspond to desired pool location._
   * Generalize the way in which I specify the URI of the `libvirt` daemon.  
        _Just as with the location of pools, use `.tfvars` files._
   * Conflicts which result from the destruction of the `jenkins_network` network.  
        _A possible solution is outlined above._
   * The location an preservation of images based on TKL.  These are `ansible` 
        and the `jenkins` controller.
   * I must find a way to save and restore a configuration.  _I could use 
    the `libvirt` domain state diagram as a model.  That is build scripts 
    named `define.sh`, `undefine.sh`, `create.sh`, `shutdown.sh`, etc.  
    These scripts would use the YAML configuration file to take appropriate action._



## How to properly change a storage directory
I found the following quote at
[this](https://serverfault.com/questions/1104983/migrating-libvirt-guest-vm-to-a-new-storage-directory-on-the-same-host)
site.
> 
> 
> However, please take into consideration that the VM may be using a storage pool, and by best practice you can use pools to hold/manage VM storage:
> 
> Most probably you are using the default pool which will point to /var/lib/libvirt/images. You can verify this using virsh pool-list. So creating a new dir won't do anything as no storage pool is configured to point to the new dir yet.
> 
> See how the default pool looks like using virsh vol-list default.
> 
> Rather create a new pool to keep things clean.
> 
> Now what you need to do is:
> 
> Create the pool > 
> `virsh pool-define-as new-dir dir - - - - "/var/lib/libvirt/new-dir"`

> Create the directory
> `mkdir -p "/var/lib/libvirt/new-dir"`
> Make sure the permissions are set correctly.
> chown qemu:qemu "/var/lib/libvirt/new-dir"

> If you run on RHEL based systems you need to run restorecon for the SELinux relabling
> `restorecon -vvRF /var/lib/libvirt/new-dir`

> Now let's build the pool
> `virsh pool-build new-dir`

> Start the pool
> `virsh pool-start new-dir`

> If you want the pool to autostart on the next reboot you'd need to run
> `virsh pool-autostart new-dir`

> Finally run
> `virsh pool-list && virsh pool-info new-dir`

> Migrate VM to the new pool
> 
> Copy the images to the new dir
> `cp -a /var/lib/libvirt/images/my-vm-name /var/lib/libvirt/new-dir/`

> Now dump my-vm-name definition to xml
> `virsh dumpxml my-vm-name > new-vm-name`
>
> Change the location (as you already mentioned in your question) to the new location
> `sed -i 's/images/new-dir/g;s/my-vm-name/new-vm-name/' new-vm-name`
>
> .. and finally define the new VM and start it
> `virsh define new-vm-name && virsh start new-vm-name`
