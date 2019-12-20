
# Bootstrap

## system

```bash

cd system

instance_name=xxx
zone=asia-east1-a

# CREATE INSTANCE
# check:
#   - machine_type
#   - network
#   - subnet
#   - boot_disk_size
#   - debian
sh ./instance.sh $instance_name $zone $private_ip

# CREATE AND ATTACH DISK
# check:
#   - disk_name
#   - type
#   - size
sh ./disk.sh $instance_name $zone

# COPY SCRIPTS
sh ./scps.sh $instance_name $zone

# EXEC BOOTSTRAP
gcloud compute ssh $instance_name --zone $zone --tunnel-through-iap -- 'sh bootstrap'
gcloud compute ssh $instance_name --zone $zone --tunnel-through-iap -- 'sh mkfs_mount_fstab'

```

## mongodb

```bash

# Prepare
cd mongodb
sh ./scps.sh $instance_name $zone
gcloud compute ssh $instance_name --zone $zone --tunnel-through-iap

# In instance
cd mongodb
sh keychown
sh mongod

# Primary Only
sh mongo-rs $ip0 $ip1 $ip2
sh mongo-admin

# Check
sh mongo-shell $ip0 $ip1 $ip2 $user_name

```
