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

gcloud compute ssh $instance_name --zone $zone --tunnel-through-iap -- 'mkdir mongodb'
cp2instance ./keyfile ~/mongodb
cp2instance ./keychown ~/mongodb
cp2instance ./mongod ~/mongodb
cp2instance ./mongo-admin ~/mongodb
cp2instance ./mongo-shell ~/mongodb
cp2instance ./mongo-rs ~/mongodb

echo "[ssh] gcloud compute ssh $instance_name --zone $zone --tunnel-through-iap"
