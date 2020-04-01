#!/bin/sh

if [ $# -ne 4  ]; then
  echo usage: $0 instance_name zone disk_suffix size
  exit 1
fi

instance_name=$1 # x
zone=$2 # asia-east1-a
disk_suffix=$3
disk_name="$instance_name-$disk_suffix"

type=pd-ssd
size=$4 # 5120GB

gcloud beta compute disks create $disk_name \
  --zone $zone \
  --type $type \
  --size $size && \
  gcloud compute instances attach-disk $instance_name --zone $zone --disk $disk_name
