
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

I placed the VMs in a `NAT` network with `CIDR` 172.32.0.0/24.  I tried a 'route' network but I ran into problems.  The network is named `jenkins_network`.

The network is created and deleted by `terraform`. This poses problems for TKL appliances.  See below for a discussion.

## Regarding TKL appliances

I used TKL appliances for the `jenkins` controller and for `ansible`.  

For the `jenkins` controller, I did an `apt-get update` followed by an `apt-get upgrade`.  (Note that this led to a minor problem, but I can't remember what it was.)  I also upgraded `Java` to "version 17".   This means that the worker will also require this version of `Java`.

Using TKL appliances is problematic since they lose their network if I use `terraform` to destroy `jenkins_network`.


## Regarding the VMs built with `terraform`

The `jenkins` agent is built with `terraform`.  These VMs will have to be configured with `ansible`.

I used a _Debian_ image for the `jenkins` agent.  I ran into the following problems:
* The firmware was not installed.  This resulted in an error message at boot time, but it was not fatal.
* The `terraform` configuration used the `eth0` interface.  This disabled network access.  I altered the `terraform` scripts to resolve the problem.

The configuration steps will require the installation of at least:
* `Java` version 17
* `docker`


## The need for a top level configuration file

It is apparent that a number of configuration parameters will have to be shared between 
shell scripts, `terraform` configuration files and `ansible` configuration files.  
I am inclined to build this file in YAML.  I could use `yq` to extract the necessary 
information.  I would have preferred JSON but I can't place comments in these files.

<pre>
common:
  foo: bar
  bar: foo

network:
  name: jenkins_network
  type: nat
  cidr: 172.32.0.0/24

pools:
  -name: pool_1
   type: dir
   location: /scratch
   description: A short description
  -name: pool_2
   type: dir
   location: /scratch
   description: A short description
  -name: pool_3
   type: dir
   location: /scratch
   description: A short description

ansible:
  hostname: ansible

vault:
  hostname: vault

jenkins:
  hostname: jenkins

jenkins_agent:
  - name: agent_1
  - name: agent_2
  
- path: /instance_groups/name=jumpbox/jobs/-
  type: replace
  value:
    name: pre-start-script
    release: os-conf
    properties:
      script: |-
               #!/bin/bash
               hostname ((internal_tag_name))


</pre>

## The Use-Cases

The scripts will be used under various circumstances.  This section details the use-cases.  
They are based on the `libvirt` domain state transition diagram.

1. *Define a deployment* The user wishes to create all of the resources described in the YAML configuration file.  
This is a two stage process, where first the core resources are defined and started.  
Once the core resources exist the other resources may be created.  The first stage 
will entail running shell scripts and `terraform` scripts.  The second stage should 
be fully automated.  To be consistent with the `libvirt` state diagram, at the 
completion of the work, the VMs should all be in the 'Defined' state.

1. *Undefine a deployment* The user wishes to destroy all of the resources created 
to 'Define' the deployment.  
This is a destructive use-case, so the user should be prompted to affirm that he 
wishes to carry out this operation.  Note that, once again, the VMs should be in 
the 'Defined' state.  Note that the result of this use-case is the deletion of 
all pools, volumes, VMs, networks etc.  

1.  *Start a deployment* The use wishes to start the VMs.  No resources are added or deleted.

1.  *Shutdown a deployment* The user wishes to shutdown the VMs.  No resources are added or deleted.

1.  *Save a deployment* The user wishes to save the resources essential to reconstruction 
of the deployment.  Some resources are easily recreated; for example a network 
or a `cloud-init` configuration.  Other resources are nearly impossible to recreate; 
for example a virtual data disk or a virtual disk which stores a VM OS.  The result 
of this use case is a collection of pools which mirror the pools of the deployment.  
These pools store the volumes required for the deployment.  Note that we deviate 
from the state diagram. We cannot save or restore from the 'Running' state.  We 
must be in either the 'Paused' state or the 'Defined' state.


1.  Restore a deployment

1.  Pause a deployment

## Detailed steps for 'Define a deployment'

### Initial stage

1. Build the network.
I am currently building the network with `terraform`.  This is problematic, since 
this means that the network is destroyed with a `terraform destroy`.  
A possible solution is as follows:
   1.  Create the network with a script which run `virsh`.  (Note that the name of the network should be extracted from the YAML configuration.)
   1.  Import the infrastructure resource which corresponds to the network and assign it to a resource block.
   1.  All resources which require this resource must include the `depends_on` argument.
1. Build the storage pools
   * The pool for all ISOs
   * The pool of OS disk images
   * The pool of general purpose disk images
   * The pool of saved disk images
1.  Build the required volumes
    * Build the volumes from OS ISOs
    * Build the volumes for cloud-image ISOs
1. Build the TKL VMs
   1. Build and configure the `ansible` host.
      * Note that this host will be configured by hand.
      * I must extract the SSH keys
      * Python-3 must be installed on this host.
   1.  Use the `TKLPatch` package to modify the other TKL ISOs.  For example, 
    I should add the `ansible` public key to the `.ssh/authorized_keys` 
    file of the root accounts.
   1. Build the `jenkins` controller host.
1. Store data in `ansible-vault`
   1. The SSH key values
      1. For the `jenkins` controller
      1. For the `ansible` host
1.  Configure the `jenkins` controller
   1. Add the `ansible` public key to the `authorized_keys` file.
   1. What else?  In any case from this point on we use `ansible`.
1. Build the `terraform` resources
   1. Build the pools
   1. Build the volumes
   1. Build the VMs
      1. Build the `vault` VM
      1. Build the `jenkins` agent(s)


### Second stage

At this point we have created the pools required for the deployment.  We have also 
created and configured an `ansible` instance along with a `vault` instance.  
We expect that all required secrets are stored in the `vault` instance.  We also 
expect that the ansible instance is properly configured.  The second stage will 
create the rest of the core instances and configure them with `ansible`.  These 
instances include:
* The `jenkins` controller
* One or more `jenkins` agent
* A `bacula` instance


### Postlog

Be sure that all VMs are returned to a 'Defined' state.


## Detailed steps for 'Start a deployment'

We are assuming that when we 'Define' the deployment the VMs/domains are in the 'Defined' state.
The processing which corresponds to this use-case is to command each VM to enter the 'Running' state.

## Detailed steps for 'Shutdown a deployment'

The processing which corresponds to this use-case is to command each VM to enter the 'Defined' state.

## Detailed steps for 'Save a deployment'

The only dynamic components of the deployment are the VMs/domains.  Hence we can safely ignore

## Detailed steps for 'Undefine a deployment'

## Detailed steps for 'Restore a deployment'

## Detailed steps for 'Suspend a deployment'

## Detailed steps for 'Resume a deployment'

## Issues which must be resolved

   * Generalize the way in which I specify the location of the pools.
I believe that the location is set with a variable which has a default.  _The solution could be to remove the default and use `.tfvars` files which correspond to desired pool location._
   * Generalize the way in which I specify the URI of the `libvirt` daemon.  _Just as with the location of pools, use `.tfvars` files._
   * Conflicts which result from the destruction of the `jenkins_network` network.  _A possible solution is outlined above._
   * The location an preservation of images based on TKL.  These are `ansible` and the `jenkins` controller.
   * I must find a way to save and restore a configuration.  _I could use the `libvirt` domain state diagram as a model.  That is build scripts named `define.sh`, `undefine.sh`, `create.sh`, `shutdown.sh`, etc.  These scripts would use the YAML configuration file to take appropriate action._
