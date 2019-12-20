#!/bin/sh

if [ $# -ne 2  ]; then
  echo usage: $0 instance_name zone
  exit 1
fi

instance_name=$1 # x
zone=$2 # asia-east1-a

disk_name="$instance_name-db"

type=pd-ssd
size=10GB

gcloud beta compute disks create $disk_name \
  --zone $zone \
  --type $type \
  --size $size && \
  gcloud compute instances attach-disk $instance_name --zone $zone --disk $disk_name
