
## Objective
The objective is a development environment on the cloud

<figure>
  <img src="./docs/final_arch.png"   width="400" height="200" 
      alt="foobar">
  <figcaption> The target architecture.</figcaption>
</figure>
# ![The target architecture](./docs/final_arch.png "Final Architecture")

## The plan in general
The plan is to proceed as follows:
- Develop on the `cuda` machine with `libvirt`.
- Use Terraform with progressively complex scripts.
- Convert to a template.
- Deploy onto a free IaaS platform.
- Deploy onto GCloud.

## How to test

### Deployment with `libvirt`
#### Deployment 1
<figure>
  <img src="./docs/libvirt_arch_1.png"   width="400" height="200" 
      alt="foobar">
  <figcaption> The target architecture.</figcaption>
</figure>

- A single host
- The 'Perimeter Network'

#### Deployment 2
<figure>
  <img src="./docs/libvirt_arch_2.png"   width="400" height="200" 
      alt="foobar">
  <figcaption> The target architecture.</figcaption>
</figure>

- A single host 
- The "Perimeter Network"
- Improve the firewall with an 'external router'

#### Deployment 3
<figure>
  <img src="./docs/libvirt_arch_3.png"   width="400" height="200" 
      alt="foobar">
  <figcaption> The target architecture.</figcaption>
</figure>

- A single host 
- The "Perimeter Network"
- Improve the firewall with an 'external router'
- Add the "internal network"
- Add the 'internal router'


#### Deployment 4

### Deployment with `terraform` templates

### Deployment onto GCloud


## Status

- 3 Dec 2025
