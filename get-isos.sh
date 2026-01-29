#!/bin/bash

# script to download ISOs 

# check destination directory
# For each ISO
#  download the signature and hash
#  download the image
#  verify the image


. utils.sh

CODENAME=bookworm # NOTE update this to relevant release codename
TK_KEY_VERSION=18.x # NOTE update this to the relevant TKL version
TK_VERSION=18.1     # NOTE update this to the relevant TKL version

iso_storage=`yq '.common.iso_storage' deployment_cfg.yaml`

if [ ! -d $iso_storage ]; then
  print_error "The directory named $iso_storage is problematic.  Aborting!"
  exit 1
fi

print_warning "Use a temporary directory"
json_file_name="t.json"

############### ############### ############### ###############
# Extract the ISO objects from the configuration YAML
yq -o=json '.isos' deployment_cfg.yaml > $json_file_name


############### ############### ############### ###############
# Download the ISOs
set +x
declare -i nof_objs=`jq -r '.|length' $json_file_name`
for (( n=0; n < nof_objs; ++n )); do 
  for nm in name mirror image hash; do
    #print_info $nm
    ts=`jq -r --arg n $n  --arg nm "$nm" '.[$n|tonumber].[$nm]' $json_file_name `
    #printf "    %-12s      : \"%s\"\n" $nm $ts 
    eval "$nm=$ts"
  done
  print_info "working on ISO named $name "

  pushd $iso_storage

      iso_file_name=$name.iso.tgz
      if [ ! -f $iso_file_name ]; then
        curl -o $iso_file_name -X GET ${mirror}${image}
        if [ $? -ne 0 ]; then
          print_error "Failed the curl call for $name."
          exit 1
        fi
      else
          print_warning "The file named $iso_file_name already exists."
      fi
      hash_file_name=$name.hash
      if [ ! -f $hash_file_name ]; then
        curl -o $hash_file_name -X GET ${mirror}${hash}
        if [ $? -ne 0 ]; then
          print_error "Failed the curl call for $name."
          exit 1
        fi
      else
          print_warning "The file named $hash_file_name already exists."
      fi


      # Check the ISO. See https://www.turnkeylinux.org/docs/release-verification

      #curl  https://raw.githubusercontent.com/turnkeylinux/common/master/keys/tkl-$CODENAME-images.asc | gpg --import
      curl https://raw.githubusercontent.com/turnkeylinux/common/refs/heads/${TK_KEY_VERSION}/keys/tkl-${CODENAME}-images.asc \
              | gpg --import

      print_warning "Use gpgv instead!"
      #gpg --list-keys --with-fingerprint release-$CODENAME-images@turnkeylinux.org
      gpg --verify ${hash_file_name}


  popd 
done






#
#
#-----BEGIN PGP SIGNED MESSAGE-----
#Hash: SHA512
#
#To ensure the image has not been corrupted in transmit or tampered with,
#perform the following two steps to cryptographically verify image integrity:
#
#1. Verify the authenticity of this file by checking that it is signed with our
#   GPG release key:
#
#    $ curl  | gpg --import
#    $ gpg --list-keys --with-fingerprint release-bookworm-images@turnkeylinux.org
#      pub   rsa4096 2023-05-22 [SC] [expires: 2043-05-17]
#            2614 7592 087C 0EDE 4214  3B63 7761 DEBA BBCF BA7C
#      uid           [ unknown] TurnKey GNU/Linux Bookworm Images (GPG signing key for TurnKey Linux Bookworm Images) <release-bookworm-images@turnkeylinux.org>
#      sub   rsa4096 2023-05-22 [S] [expires: 2043-05-17]
#      
#    $ gpg --verify debian-12-turnkey-ansible_18.0-1_amd64.tar.gz.hash
#      gpg: Signature made using RSA key ID 26147592087C0EDE42143B637761DEBABBCFBA7C
#      gpg: Good signature from "0"
#
#2. Recalculate the image hash and make sure it matches your choice of hash below.
#
#    $ sha256sum debian-12-turnkey-ansible_18.0-1_amd64.tar.gz
#      35de750edafdd036f8a54b4fb8300c879599a7c46ab38e0d7d60b7ce51b7e475  debian-12-turnkey-ansible_18.0-1_amd64.tar.gz
#
#    $ sha512sum debian-12-turnkey-ansible_18.0-1_amd64.tar.gz
#      2317b91a2d804fd5d17005695b4bd62c5833cbe81182529da03d68ffbacc4d88fb5f47b915f3a9f1d90203476f9555c85692362d5a077458eb4048147f0fee6b  debian-12-turnkey-ansible_18.0-1_amd64.tar.gz
#
#   Note, you can compare hashes automatically::
#
#    $ sha256sum -c debian-12-turnkey-ansible_18.0-1_amd64.tar.gz.hash
#      debian-12-turnkey-ansible_18.0-1_amd64.tar.gz: OK
#
#    $ sha512sum -c debian-12-turnkey-ansible_18.0-1_amd64.tar.gz.hash
#      debian-12-turnkey-ansible_18.0-1_amd64.tar.gz: OK
#
#    Final note, when checking SHAs automatically, please ignore warning noting that some lines are improperly formatted.
#
#-----BEGIN PGP SIGNATURE-----
#
#iQIzBAEBCgAdFiEE0achB3UVKiMsY4ckkPLGHN5q3jcFAmYx8GgACgkQkPLGHN5q
#3jcMpw//UiYHpgD4hhA30d7/qp0mJQ6JV7RIj6eld8qMMuRGNED5DAbMOQ/3kpzp
#piGlweLzbqpGcr7X+p22S/D+IZZinmOe2YsqJBdbu1UmZXzb0kDchl5R0aTmSqUD
#1SnY1/UeIp/lnvS7iak5/IEsqlWT0JziQtSF0cD7o0aIJILuJqrI6fpQ34Ap7qGG
#c+Y597W4tKN1nlYeMO4Z09lM/faN/UHfoAOyBvBtmoMnouGxUyNIPQU4jnqmQakW
#98r1smIfbfWc5N8b/gg8C1KZhp2JQ5/7he/Fjjdbe4252EytM2HcnEVC34LPCWyI
#8I8O0s2cRWmvOO9/gyQD+nuxAlp28j0gNPwOG1/Z8fY4yN5zMCuccl3net3qMKKE
#wSmMP8LMzsPHLP4o0GIY2rUwGw7QTZfHQctE4Oj0PKXdsbuscKe9Ajtq6WoRlA1c
#qM0DXloqZCV9oEgXKgpQlXNVMxck/mr5LZFYUdnyjNfwOk8MDXvAOA7+gwWwgfrL
#N6DR/If9BNcrKpKeTKh3yIqirIAa5huRIKAyjWC9qo2r2Km+MGR/ea8tAxUlcl+O
#CjlwtnYCWOs9HwsRSWY4cppOSIDeKoFBWqJNIU4K7xAOX+oACpGbesUmahGkiOoP
#3me55Qztbp5LZTptsDzvM4A3DnXyjwt4GbvTOhv6PAo1BPLAyb0=
#=cOBS
#-----END PGP SIGNATURE-----




 gpg --list-keys --with-fingerprint release-bookworm-images@turnkeylinux.org
