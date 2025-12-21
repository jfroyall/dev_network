
DEST_DIR=~/scratch/
SERVER=http://mirror.turnkeylinux.org/turnkeylinux/images/iso/

APPS="core-18.1-bookworm \
      jenkins-18.0-bookworm
      mysql-18.1-bookworm \
      nginx-php-fastcgi-18.0-bookworm \
      redmine-18.1-bookworm \
      "
APPS="core-18.1-bookworm" 

echo $APPS
for a in $APPS; do

  echo $a
  file_name="turnkey-$a-amd64.iso"
  echo $file_name
  url="${SERVER}${file_name}"
  echo $url
  echo "---"
  curl $url > ${DEST_DIR}$file_name

done
