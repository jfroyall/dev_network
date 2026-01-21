

export VIRSH_DEFAULT_CONNECT_URI="qemu+ssh://jean@192.168.1.96/system?keyfile=/home/jean/.ssh/id_rsa&no_verify=0&sshauth=privkey"

#for d in ansible nginx jumpbox vault; do 

for host in jumpbox vault nginx; do
  for subnet in  control internal; do
    for branch in  dev test prod ; do
      for d in ${host}.${subnet}.${branch}; do 
      echo $d; 
        virsh  undefine $d
        #virsh  shutdown $d  && virsh  undefine $d
        #virsh -c qemu:///system shutdown $d && virsh -c qemu:///system undefine $d
      done
    done
  done
done


#virsh -c qemu:///system shutdown alpine-vm-0 && virsh -c qemu:///system undefine alpine-vm-0
#virsh -c qemu:///system shutdown alpine-vm-1 && virsh -c qemu:///system undefine alpine-vm-1
