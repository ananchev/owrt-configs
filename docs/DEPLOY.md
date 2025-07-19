# Deployment & Router Copy Commands

This file describes how to merge wireless configs and deploy configuration files to your OpenWrt routers.

## Merging Wireless Configs
Run:
```sh
./merge_wireless.sh
```
This creates the merged `wireless` file for deployment at `common/etc/config/wireless`.

## Copying Files to Routers

### Common Files
For each file in `common/etc/config/`:
```sh
scp -O -i ~/.ssh/id_rsa_tomatoes common/etc/config/wireless root@owrt:/etc/config/wireless
scp -O -i ~/.ssh/id_rsa_tomatoes common/etc/config/wireless root@owrt2:/etc/config/wireless
```

### Device-Specific Files
For `owrt`:
```sh
scp -O -i ~/.ssh/id_rsa_tomatoes owrt/etc/config/network root@owrt:/etc/config/network
scp -O -i ~/.ssh/id_rsa_tomatoes owrt/etc/config/wireless root@owrt:/etc/config/wireless
scp -O -i ~/.ssh/id_rsa_tomatoes owrt/etc/config/dawn root@owrt:/etc/config/dawn
```
For `owrt2`:
```sh
scp -O -i ~/.ssh/id_rsa_tomatoes owrt2/etc/config/network root@owrt2:/etc/config/network
scp -O -i ~/.ssh/id_rsa_tomatoes owrt2/etc/config/wireless root@owrt2:/etc/config/wireless
scp -O -i ~/.ssh/id_rsa_tomatoes owrt2/etc/config/dawn root@owrt2:/etc/config/dawn
```

## Applying and Verifying Changes
SSH into each router and run:
```sh
/etc/init.d/network restart
/etc/init.d/dawn restart
```
