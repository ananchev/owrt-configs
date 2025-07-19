# OpenWrt VPN Setup Guide (Simplified)

## Overview

This guide explains how to set up an OpenWrt router as a VPN gateway: it connects to an upstream router and provides LAN devices with secure access to remote networks via VPN.

## Network Architecture

### Topology
```
Internet
    ↓
ISP/Upstream Router
    ↓
WAN Port (OpenWrt)
    ↓
OpenWrt Router (LAN: 192.168.88.1)
    ↓
LAN Devices (DHCP: 192.168.88.100-199)
    ↓
VPN Tunnel (OpenVPN)
    ↓
Remote Networks (e.g., 192.168.5.0/24, 10.128.128.0/24)
```

### Key Points
- OpenWrt LAN: 192.168.88.1/24
- DHCP range: 192.168.88.100-199
- WAN/LAN ports separated via VLANs
- All LAN clients have full VPN access
- Reverse SSH tunnel for backup management

## OpenVPN Client Configuration

**File**: `/etc/openvpn/decowrl.ovpn`

```bash
remote connect.tonio.cc 1195 udp
client
nobind
dev tun
verb 4
cipher CHACHA20-POLY1305
data-ciphers CHACHA20-POLY1305:AES-128-GCM:AES-256-GCM
key-direction 1
tls-client
remote-cert-tls server
route-nopull
script-security 2
route 192.168.5.0 255.255.255.0
route 10.128.128.0 255.255.255.0
dhcp-option DNS 1.1.1.1
persist-key
persist-tun
resolv-retry infinite
ca /etc/openvpn/ca.crt
cert /etc/openvpn/client.crt
key /etc/openvpn/client.key
tls-auth /etc/openvpn/ta.key 1
```

- Certificate and key files (`ca.crt`, `client.crt`, `client.key`, `ta.key`) are stored separately in `/etc/openvpn/` and referenced by the config above.
- VPN routes are managed by OpenVPN and only active when the tunnel is up.
- No DHCP route injection; all LAN clients have full VPN access.

## Network Configuration

**File**: `/etc/config/network`

```bash
config interface 'lan'
    option device 'br-lan'
    option proto 'static'
    option ipaddr '192.168.88.1'
    option netmask '255.255.255.0'
    option gateway '192.168.88.1'
    option dns '8.8.8.8 1.1.1.1'

config interface 'wan'
    option device 'eth0.1'
    option proto 'dhcp'

config device
    option name 'br-lan'
    option type 'bridge'
    list ports 'eth0.2'

config switch_vlan
    option device 'switch0'
    option vlan '1'
    option ports '0t 3'
    option vid '1'
# VLAN 1: CPU + port 3 (LAN)

config switch_vlan
    option device 'switch0'
    option vlan '2'
    option ports '0t 5'
    option vid '2'
# VLAN 2: CPU + port 5 (WAN)

config interface 'openvpn'
    option proto 'none'
    option device 'tun0'
```

## DHCP Configuration

**File**: `/etc/config/dhcp`

```bash
config dhcp 'lan'
    option interface 'lan'
    option start '100'
    option limit '100'
    option leasetime '12h'
    option dhcpv4 'server'
    option dhcpv6 'server'
    option ra 'server'
    list ra_flags 'managed-config'
    list ra_flags 'other-config'
```

- DHCP range: 192.168.88.100-199
- No custom DHCP options for route injection

## Wireless Configuration

**File**: `/etc/config/wireless`

- Both radios are bridged to LAN
- All WiFi clients get full LAN and VPN access

## Reverse SSH Tunnel

**File**: `/usr/bin/reverse-ssh-tunnel.sh`
- Provides backup access via remote server
- Service script: `/etc/init.d/reverse-ssh-tunnel`
- Enable with `/etc/init.d/reverse-ssh-tunnel enable`

## Firewall / NAT

- Disabled for simplicity
- Security handled by upstream router and VPN server
- **NAT masquerading is required for LAN clients to access both VPN and Internet.**
- Add these rules to `/etc/rc.local` before `exit 0` to persist after reboot:

```bash
nft add table inet nat
nft add chain inet nat postrouting { type nat hook postrouting priority 100 \; }
nft add rule inet nat postrouting oifname "tun0" ip saddr 192.168.88.0/24 counter masquerade
nft add rule inet nat postrouting oifname "eth0.1" ip saddr 192.168.88.0/24 counter masquerade
```

## Service Management

```bash
# Network
/etc/init.d/network restart

# OpenVPN
/etc/init.d/openvpn restart

# DHCP
/etc/init.d/dnsmasq restart

# Reverse SSH Tunnel
/etc/init.d/reverse-ssh-tunnel restart
```

## Testing

- Connect LAN device, verify DHCP IP in 192.168.88.100-199
- Connect to WiFi, verify LAN/VPN access
- Test VPN connectivity: `ping 192.168.5.1`, `ping 10.128.128.1`
- Test reverse SSH tunnel from remote server
