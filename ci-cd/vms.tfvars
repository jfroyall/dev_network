
## ## ## ## ## ## ## ## ## ##
##  ------   Important DO NOT add redmine until later!
##  ------   Important DO NOT add redmine until later!
## ## ## ## ## ## ## ## ## ##
#Be sure to update 'undefine.sh' if you add more VMs

all_vms ={
          jumpbox = {
            name    : "jumpbox"
            sof_mem : 1*1024*1024*1024
            sof_disk: 2*1024*1024*1024
            image   : "alpine"
            network : "control"
            user_data : "user-data.yaml.tpl"
          },
          vault = {
            name    : "vault"
            sof_mem : 1*1024*1024*1024
            sof_disk: 2*1024*1024*10240
            image   : "alpine"
            network : "control"
            user_data : "vault-user-data.yaml.tpl"
          },
/*
          ansible = {
            name    : "ansible"
            sof_mem : 1*1024*1024*10240
            sof_disk: 2*1024*1024*10240
            image   : "alpine"
            network : "control"
            user_data : "ansible-user-data.yaml.tpl"
          },
          nginx = {
            name    : "nginx"
            sof_mem : 1*1024*1024*10240
            sof_disk: 2*1024*1024*10240
            image   : "alpine"
            network : "control"
            user_data : "user-data.yaml.tpl"
          },
*/
}
