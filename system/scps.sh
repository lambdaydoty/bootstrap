#!/bin/sh

if [ $# -ne 2  ]; then
  echo usage: $0 instance_name zone
  exit 1
fi

instance_name=$1 # x
zone=$2 # asia-east1-a

cp2instance () {
  gcloud compute scp $1 $instance_name:$2 --zone $zone --tunnel-through-iap
}

# cp2instance ./ssh_config ~/.ssh/config
# cp2instance ./id_rsa.github ~/.ssh/
# cp2instance ./id_rsa.github.pub ~/.ssh/
cp2instance ./bootstrap ~
cp2instance ./mkfs_mount_fstab ~

echo "[ssh] gcloud compute ssh $instance_name --zone $zone --tunnel-through-iap"
