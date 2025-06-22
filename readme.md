# My OpenWrt

This repository manages OpenWrt UCI configuration files for multiple routers, separating common/shared configs from device-specific ones. Sensitive data (like Wi-Fi passwords) is encrypted and never stored in plain text.

---

### Configuration Files

- **dhcp**: DHCP and DNS server settings.
- **dawn**: DAWN (Decentralized Wireless Controller) settings.
- **dropbear**: SSH server configuration.
- **ethers**: Static DHCP assignments (MAC-to-IP).
- **firewall**: Firewall rules and zones.
- **luci**: LuCI web interface settings.
- **network**: Network interfaces, bridges, VLANs.
- **rpcd**: RPC daemon settings.
- **system**: System settings (hostname, timezone, NTP).
- **uhttpd**: Web server configuration.
- **ubootenv**: U-Boot environment settings.
- **ucitrack**: UCI configuration tracking.
- **umdns**: Multicast DNS settings.
- **wireless**: Wireless radio and interfaces configuration.
- **sysctl.conf**: Kernel/network tuning parameters.
- **dawn-opkg**, **dawn.old**: Alternative or backup DAWN configs.

#### Wireless Configuration (Sensitive Data)
- **wireless.main**: Non-sensitive wireless configuration (SSID, channel, etc.).
- **wireless.key**: Contains only the Wi-Fi password line(s) (`option key 'your_wifi_password'`).  
  *Encrypted before committing to the repository.*
- **wireless**: The merged file (created by `merge_wireless.sh`) for deployment to the router.  
  *Ignored by git to avoid leaking secrets.*

---

## Repository Structure

```
common/
  firewall         # Firewall rules and zones
  luci             # LuCI web interface settings
  rpcd             # RPC daemon settings
  uhttpd           # Web server configuration
  ucitrack         # UCI configuration tracking
  umdns            # Multicast DNS settings
  wireless.main    # Device-specific, non-sensitive wireless config
  wireless.key     # Device-specific, encrypted Wi-Fi password(s)
  wireless         # Merged for deployment (ignored by git)
  dhcp             # Device-specific DHCP and DNS server settings
  dropbear         # Device-specific SSH server configuration
  ubootenv         # Device-specific U-Boot environment settings
  sysctl.conf      # Kernel/network tuning parameters
  ethers           # Static DHCP assignments
  # Add any other config files that are identical for all routers

owrt/ and owrt2/
  network          # Device-specific network config`
  system           # System settings
  dawn             # Device-specific DAWN settings
  dawn-opkg        # Default (OOTB) DAWN config
  # Any other device-specific config files or overrides

encrypt.sh             # Script to encrypt files 
decrypt.sh             # Script to decrypt files
merge_wireless.sh      # Script to merge wireless.main and wireless.key
.gitattributes         # Git filters for encryption/decryption
.gitignore             # Ignore merged wireless files
```

**Claridications:**
- `common/`: Contains configuration files that are identical for all routers. These are copied to each device during deployment unless overridden by a device-specific file.
- `owrt/` and `owrt2/`: Contain device-specific configuration files. Any file here overrides the corresponding file from `common/`.
- `wireless.main` and `wireless.key`: Split for security; only the key file is encrypted. 
  **Important:**  
  - The order of `option key` lines in `wireless.key` **must match** the order of the corresponding `wifi-iface` sections in `wireless.main`.
  - **Do not include any `option key` lines in `wireless.main`.**

- `wireless`: Merged before deployment, ignored by git.
- `encrypt.sh` / `decrypt.sh`: Scripts for encrypting/decrypting sensitive files.
- `merge_wireless.sh`: Script to merge wireless.main and wireless.key for deployment.
- `.gitattributes`: Configures git filters for automatic encryption/decryption.
- `.gitignore`: Ensures merged `wireless` files are not committed.
---

## Setting Up Git Filters for Encrypted Files

Git filters with Ansible Vault are used to ensure sensitive files (like `wireless.key`) are always encrypted in the repository and automatically decrypted upon check out locally.

### 1. Filter Scripts

**encrypt.sh**
```sh
#!/bin/sh
ansible-vault encrypt --output - -
```

**decrypt.sh**
```sh
#!/bin/sh
ansible-vault decrypt --output - -
```
Scripts should be made executable

### 2. Create `.gitattributes` file to apply the filter to  sensitive files:
```
common/wireless.key filter=ansible-vault
```

This tells Git to use the `ansible-vault` filter for these files.

### 3. Add the following to the local `.git/config` to set the actions performed by the filter:

```ini
[filter "ansible-vault"]
    clean = ./encrypt.sh
    smudge = ./decrypt.sh
```
- The `clean` command is run when adding files to the repository (encrypts them).
- The `smudge` command is run when checking files out (decrypts them).

With this configuration, upon commit and push, the encrypted version is stored in the repository, but when performing check out or edit, Git will automatically decrypt the files locally when the vault password is supplied correctly.


### 4. Initial Encryption of `wireless.key` files:
```sh
ansible-vault encrypt common/wireless.key
```
Vault password is **Ansible vault for home infrastructure**

---

## .gitignore

Ensures merged `wireless` files are not committed to the repository.
```
common/wireless
```

---

## merge_wireless.sh

Shell script to merge `wireless.main` and `wireless.key` into `wireless` file, ready for deployment. 

Usage:
```sh
./merge_wireless.sh
```


---

## Copying Files **To** the Router (Restore/Deploy)

### 1. Copying Common Config Files

For each file in `common/` (example for `firewall` and `ethers`):
```sh
scp -O -i ~/.ssh/id_rsa_tomatoes common/firewall root@owrt:/etc/config/firewall
scp -O -i ~/.ssh/id_rsa_tomatoes common/firewall root@owrt2:/etc/config/firewall
scp -O -i ~/.ssh/id_rsa_tomatoes common/ethers root@owrt:/etc/ethers
scp -O -i ~/.ssh/id_rsa_tomatoes common/ethers root@owrt2:/etc/ethers
# Repeat for each common config file
```

### 2. Copying Device-Specific Files to `owrt`

```sh
scp -O -i ~/.ssh/id_rsa_tomatoes owrt/network root@owrt:/etc/config/network
scp -O -i ~/.ssh/id_rsa_tomatoes owrt/wireless root@owrt:/etc/config/wireless
scp -O -i ~/.ssh/id_rsa_tomatoes owrt/dawn root@owrt:/etc/config/dawn
# Repeat for other device-specific files as needed
```

### 3. Copying Device-Specific Files to `owrt2`

```sh
scp -O -i ~/.ssh/id_rsa_tomatoes owrt2/network root@owrt2:/etc/config/network
scp -O -i ~/.ssh/id_rsa_tomatoes owrt2/wireless root@owrt2:/etc/config/wireless
scp -O -i ~/.ssh/id_rsa_tomatoes owrt2/dawn root@owrt2:/etc/config/dawn
# Repeat for other device-specific files as needed
```
### 4. Apply and Check Changes

After copying configuration files to thr routers, below steps apply the changes and verify everything is working as expected:

#### **A. Restart the Network Stack and Wireless Configuration**

SSH into each router and run:
```sh
/etc/init.d/network restart
```
This command fully restarts the network stack and applies changes to `/etc/config/network` and `/etc/config/wireless`. It is more thorough than `reload` and ensures services like DAWN pick up all changes.

#### **B. Restart DAWN**

To ensure DAWN is aware of the new configuration, restart the DAWN service:
```sh
/etc/init.d/dawn restart
```

#### **C. Check Wireless Configuration**

To verify the current wireless configuration:
```sh
uci show wireless
```
Or, to check the active wireless interfaces and their settings:
```sh
iw dev
```

#### **D. Check Connected Clients and Signal Strength**

To see which clients are connected and their signal quality:
```sh
iw dev wlan0 station dump
iw dev wlan1 station dump
```
Look for device’s MAC address and review the `signal` and `tx bitrate` fields.

#### **E. Check DAWN Status**

To check if DAWN is running and see its logs:
```sh
/etc/init.d/dawn status
logread | grep dawn
```

---

**Summary:**  
1. Restart the network stack (`/etc/init.d/network restart`)
2. Restart DAWN (`/etc/init.d/dawn restart`)
3. Check wireless config and interfaces (`uci show wireless`, `iw dev`)
4. Check connected clients and signal (`iw dev wlanX station dump`)
5. Check DAWN status and logs (`/etc/init.d/dawn status`, `logread | grep dawn`)
6. Reboot if needed

This sequence ensures your configuration changes are applied and your routers and DAWN are operating as expected.

---

## Notes

- The `-O` flag forces `scp` to use the legacy SCP protocol, required for Dropbear (the default OpenWrt SSH server).
- Always review changes before deploying to avoid misconfiguration.
- After copying, you may need to reload configuration or reboot the router:
  ```sh
  ssh -i ~/.ssh/id_rsa_tomatoes root@owrt 'reload_config'
  ssh -i ~/.ssh/id_rsa_tomatoes root@owrt2 'reload_config'
  ```