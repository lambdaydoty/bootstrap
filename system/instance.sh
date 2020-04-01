#!/bin/sh

if [ $# -ne 3  ]; then
  echo usage: $0 instance_name zone ip
  exit 1
fi

instance_name=$1 # x
zone=$2 # asia-east1-a
ip=$3

machine_type=e2-standard-2

network=wallet-nat-vpc
subnet=wallet-nat-vpc-subnet-0

boot_disk_size=10GB

debian=v20191210

gcloud compute instances create $instance_name \
  --zone $zone \
  --machine-type $machine_type \
  --boot-disk-type pd-ssd \
  --boot-disk-size $boot_disk_size \
  --image debian-10-buster-$debian \
  --image-project debian-cloud \
  --network=$network \
  --subnet=$subnet \
  --no-address \
  --private-network-ip=$ip
