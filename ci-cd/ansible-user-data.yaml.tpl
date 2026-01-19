#cloud-config
#
hostname: ${host_name}
create_hostname_file: true
fqdn: ${host_name}.${network}.${branch}.home
prefer_fqdn_over_hostname: true

ssh_pwauth: true

# Demonstrate setting up an ansible controller host on boot.
# This example installs a playbook repository from a remote private repository
# and then runs two of the plays.

package_update: true
package_upgrade: true
packages:
  - openssh-server
  - git
  - python3-pip

# Set up an ansible user
# ----------------------
# In this case I give the local ansible user passwordless sudo so that ansible
# may write to a local root-only file.
users:
  - name: ansible
    gecos: Ansible User
    shell: /bin/bash
    groups: users,admin,wheel,lxd
    sudo: "ALL=(ALL) NOPASSWD:ALL"
  - name: root
    shell: /bin/sh
    lock_passwd: false
    plain_text_passwd: password

  - name: jean
    shell: /bin/sh
    lock_passwd: false
    plain_text_passwd: password


# Initialize lxd using cloud-init.
# --------------------------------
# In this example, a lxd container is
# started using ansible on boot, so having lxd initialized is required.
#lxd:
#  init:
#    storage_backend: dir

# Configure and run ansible on boot
# ---------------------------------
# Install ansible using pip, ensure that community.general collection is
# installed [1].
# Use a deploy key to clone a remote private repository then run two playbooks.
# The first playbook starts a lxd container and creates a new inventory file.
# The second playbook connects to and configures the container using ansible.
# The public version of the playbooks can be inspected here [2]
#
# [1] community.general is likely already installed by pip
# [2] https://github.com/holmanb/ansible-lxd-public
#
ansible:
  install_method: pip
  package_name: ansible
  run_user: ansible
  galaxy:
    actions:
      - ["ansible-galaxy", "collection", "install", "community.general"]

  setup_controller:
    repositories:
      - path: /home/ansible/my-repo/
        source: git@github.com:holmanb/ansible-lxd-private.git
    run_ansible:
      - playbook_dir: /home/ansible/my-repo
        playbook_name: start-lxd.yml
        timeout: 120
        forks: 1
        private_key: /home/ansible/.ssh/id_rsa
      - playbook_dir: /home/ansible/my-repo
        playbook_name: configure-lxd.yml
        become_user: ansible
        timeout: 120
        forks: 1
        private_key: /home/ansible/.ssh/id_rsa
        inventory: new_ansible_hosts

# Write a deploy key to the filesystem for ansible.
# -------------------------------------------------
# This deploy key is tied to a private github repository [1]
# This key exists to demonstrate deploy key usage in ansible
# a duplicate public copy of the repository exists here[2]
#
# [1] https://github.com/holmanb/ansible-lxd-private
# [2] https://github.com/holmanb/ansible-lxd-public
#
write_files:
  - path: /home/ansible/.ssh/known_hosts
    owner: ansible:ansible
    permissions: 0o600
    defer: true
    content: |
      |1|YJEFAk6JjnXpUjUSLFiBQS55W9E=|OLNePOn3eBa1PWhBBmt5kXsbGM4= ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
      |1|PGGnpCpqi0aakERS4BWnYxMkMwM=|Td0piZoS4ZVC0OzeuRwKcH1MusM= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
      |1|OJ89KrsNcFTOvoCP/fPGKpyUYFo=|cu7mNzF+QB/5kR0spiYmUJL7DAI= ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=

  - path: /home/ansible/.ssh/id_rsa
    owner: ansible:ansible
    permissions: 0o600
    defer: true
    content: |
      -----BEGIN PRIVATE KEY-----
      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
      GdfewNwdNnrCwoNCyykTQOOetwQj
      -----END PRIVATE KEY-----
  - path: /home/ansible/.ssh/id_rsa.pub
    owner: ansible:ansible
    permissions: 0o600
    defer: true
    content: |
      -----BEGIN PUBLIC KEY-----
      MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAtPpS+J1cNpoI61RHtpp/
      Xkj7oENfaQ0xs8snrI/Q/Klm6UO/nBccdXr/MuJ+WVVv7WpCaokCG2CJuseq4J5f
      Dv0MtoBh6vWdKCM5Jcc/XtWMGcpmwRKxVZ2JwDCgtTKNZcZkaKIqn22B3Mu4hIcw
      f/kvGXnxghw+0qsSprPYKvsAI6+TfiKm5Jw2spGn1pK6hW5NjgPq91GdGCKu0TuG
      MjW668yByjEs480TASs80MoSpzgrWAb1TF3uwYwzzKMNIXBbbOvuXjblP2o+9Oaa
      OWKDdkFAI54nsT7Q4WSHRapai3WyWKXJyZLVjh98mNlJ95PtbPQsaKkn5EU54dKG
      9k11XXBmyVMAJeipcWJOaaHQe93sdcnYoJwwoBOSIg+NIN1cfVQG4jLBx4Y2y52M
      TA1CQpo/aIlf9YUDlOQ8pcXweKG+ZcMlfLjqvsU0bvkcsF8GKOVIktHNiOlBJWaN
      whexQokeb+678qnfDuEPHLzJFp0bljA+lkvcsqjFv/menmzlQsUTe1X+iVlQiEfQ
      siUh+bsPi45Ut6zx0p/VOlFCdwH85OWIgExWZaScfnztpxqUvzl1ng0JaQMd9NLC
      SrTmQRt1iUcO9B8iZr02jMvYaJPCUVKh1EOOpLJOXHiCDJvj6yRffNz1mHV50z4U
      8jh5YBQRfBBoYBPPEbiBnxsCAwEAAQ==
      -----END PUBLIC KEY-----

