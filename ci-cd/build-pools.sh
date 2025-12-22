
ROOT_DIR=~/scratch/
for pool_name in  os-isos vm-ssds vm-images ; do

  echo "Building $pool_name"
  virsh pool-create-as $pool_name \
                        --type dir \
                        --target ${ROOT_DIR}${pool_name} \
                        --build
  if [ $? -ne 0 ]; then
    echo Failed the pool-create-as!
    exit 1
  fi
done
virsh pool-refresh vm-images

