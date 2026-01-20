# This is the plan
This document describes the plan which will be followed to construct the
'office' network.

The build should be iterative.  The first pass should deploy and configure a
small collection of VMs.  The essentials of the infrastructure should exist at
the end of this pass.

The second and subsequent passes should deploy and configure additional VMs.

There are a number of major stages:
1. Establish an architecture/topology.
1. Build the networks
1. Build the storage pools and volumes
1. Deploy and configure the first VMs.  These are the VMs which are essential
to the architecture; for example a jumpbox.
1. Deploy and configure the subsequent VMs.  These are the VMs which I are
necessary to complete a useful environment.
The required packages:
- `libvirt`
- `terraform`
- `ansible`
- `alpine` cloud images
- `jenkins` (for testing)

## Testing
There will always be three deployments.  These are the 'production'
deployments, the 'testing' deployment, and the 'development' deployment.
These deployments will correspond to similarly named git branches.  I will
work and carry out simple tests on the `dev`' branch.  Once I'm satisfied with
this revision, I will `git merge` the `dev` branch onto the `test` branch.
A deployment based on the `test` branch will be fully tested.  Once it passes
all tests, then the `test` branch will be merged with the production (i.e.,
'master') branch.

I will use `jenkins` to carry out the testing.  The `jenkins` controller will
monitor the `GitHub` repository.  When a change occurs, the appropriate
`jenkins` worker will be dispatched to deploy VMs on the 'plane' which
corresponds to the branch which was updated.  Note that only the `testing` and
`production` deployments need to be automated.  The `dev` deployment should be
managed manually.

The fact that I plan to use `jenkins` implies that a controller and a number
of workers must exist.  I will probably automate the construction of these
VMs, but they will be based on `Alpine` images.

## The architecture
- Define DNS zones

|zone|CIDR|
|---|---|
|prod.office.home.              |172.16.16.0/20|
|control.prod.office.home.      |172.16.17.0/24|
|internal.prod.office.home.     |172.16.18.0/24|
|test.office.home.              |172.17.16.0/20|
|control.test.office.home.      |172.17.17.0/24|
|internal.test.office.home.     |172.17.18.0/24|
|dev.office.home.               |172.18.16.0/20|
|control.dev.office.home.       |172.18.17.0/24|
|internal.dev.office.home.      |172.18.18.0/24|


- Define sub-networks
  -  See ![this figure](../figures/QEMU_Networking.png)

- VMs with static IP addresses
  |host|IP|
  |---|---|
  | `jenkins`| 172.16.16.128|
  | `ns1`    | 172.16.16.129|
  | `jumpbox`| 172.x.17.128|
  | `vault`  | 172.x.17.129|

## Structure of the `terraform` files
If one is not careful, the `terraform` code can become difficult to manage.
In fact the objective is to build a number of interdependent `libvirt`
resources.  The properties of these resources must be provided _a priori_.
They will be defined by a collection of `terraform` variables.  The problem is
that these variables can be used to construct various resources.

The ideal would be to construct a hierarchy of variables.  The basic variables
could be combined to define new variables which would be used to create the
resources.  This would place the burden in the construction of collections
each of which corresponds to a type of resource.  Each member of the
collection could be used to define an instance of the corresponding resource.

It seems natural to start with the object which must be provided to each type
of resource.  When if the intersection of the objects which correspond to
two resources is non-empty, then that intersection should be used to define
one or more basic variables.

These are the `terraform` resource types which I plan to build.  Each resource
is accompanied by the parameters it requires
- networks
   - Its name/label
   - DNS resolver info
   - The IP information (one per IP address)
      - The CIDR
      - The prefix or netmask
      - Ranges
      - DHCP information
   - The network's DNS domain information
   - The network's forwarding information
- pools
   - Its name/label
   - Its type (always 'dir' )
   - The location of the directory.
- backing store volumes
   - Its name/label
   - The pool where it is to be stored
   - The URL of the image resource
- copy on write volumes
   - Its name/label
   - The pool where it is to be stored
   - Its capacity
   - Its type (qcow2?)
   - Its corresponding backing store
      - path to the backing store
      - format of the backing store

- `cloudinit_disk`
   - Its name/label
   - The rest is <span style="color:red">**TBD**</span>.

- `cloud-init` ISOs
   - Its name/label
   - The pool where it is to be stored
   - The URL of the output

- domains
   - Its name/label
   - Memory requirements
   - Number of CPUs
   - OS description
   - disks
     - the pool containing the disk image
     - the volume which corresponds to the disk image
     - the type of driver
   - interfaces
     - the type of interface
     - the model
     - the source for the interface
       - one of the previously created networks
   - etc...

We could create a collection of domain descriptors which define all of the
values required to instantiate a domain.  These descriptors should be built
from more basic objects.  Similarly for copy on write volumes.

Since I plan to duplicate the architecture over a number of networks and
subnets, and since each subnet corresponds to a DNS domain I the natural key
is the FQDN of each host.  That is I must create a collection of descriptors
indexed by the FQDN of the VMs.


## Pass 1
### Build the secrets
The deployment will require cryptographic pairs and signed certificates.
These will have to constructed and stored in an `ansible-vault`.  
- `SSH` pair for:
  - admin access to all VMs
  - foobar
- Certificates for for:
  - foobar

### Build the networks:
Use `terraform` to build the networks.  I should loop over a collection of
objects.  These objects should include the following members:
1. The network name.
1. The FQDN.
1. The CIDR address of the network.

### Build the storage pools and volumes
- The pools are:
  1. `os-isos`: Storage for the ISOs required for the deployment.
  1. `vm-templates`: Storage for the 'cloud' images.  For example the Alpine
  `QCOW2` images.
  1. `vm-images`: Storage for the backstore for VM instances.
Note that the names are subject to change.
- The volumes are <span style="color:red">**TBD**</span>.
### Deploy the initial VMs
- `jumpbox`; the jump-box.
- `vault`; the HashiCorp vault.

- `ns1`; the DNS server.
### Configure the initial VMs
- `jumpbox`; the jump-box.
- `vault`; the HashiCorp vault.
   - Update the `vault` from the `ansible-vault`.
- `ns1`; the DNS server.
   - Update the `named.conf` file

## Subsequent passes
### Update the secrets
Add to the `ansible-vault` secret data base.  Subsequently add to the `vault`,
using the `ansible` updates.
### Deploy the extra VMs
The extra VMs include:
- `redmine`
- `baracuda`
- `nginx`
- `cuda`
### Configure the extra VMs
