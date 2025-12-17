
provider "libvirt" {
  # Configuration du fournisseur libvirt
  uri = "qemu+sshcmd://jean@192.168.1.96/system?keyfile=/home/jean/.ssh/id_rsa&no_verify=0&sshauth=privkey"
  #uri = "qemu:///session"

}

