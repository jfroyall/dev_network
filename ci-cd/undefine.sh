for d in ns1 jumpbox vault; do 
echo $d; 
  virsh -c qemu:///system shutdown $d && virsh -c qemu:///system undefine $d
done
#virsh -c qemu:///system shutdown alpine-vm-0 && virsh -c qemu:///system undefine alpine-vm-0
#virsh -c qemu:///system shutdown alpine-vm-1 && virsh -c qemu:///system undefine alpine-vm-1
