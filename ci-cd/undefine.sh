

export VIRSH_DEFAULT_CONNECT_URI="qemu+ssh://jean@192.168.1.96/system?keyfile=/home/jean/.ssh/id_rsa&no_verify=0&sshauth=privkey"

for d in jenkins ns1 jumpbox vault; do 
echo $d; 
  virsh  shutdown $d  && virsh  undefine $d
  #virsh -c qemu:///system shutdown $d && virsh -c qemu:///system undefine $d
done
#virsh -c qemu:///system shutdown alpine-vm-0 && virsh -c qemu:///system undefine alpine-vm-0
#virsh -c qemu:///system shutdown alpine-vm-1 && virsh -c qemu:///system undefine alpine-vm-1
