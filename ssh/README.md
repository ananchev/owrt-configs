# SSH Key Management for Router Access

This folder contains sensitive SSH keys used for key-based authentication to OpenWrt routers and remote hosts.

## Private Keys
- `id_rsa_tomatoes`: AES256-encrypted private SSH key for accessing all managed OpenWrt routers.
  - Encrypted with Ansible Vault (password: **Ansible vault for home infrastructure**).
  - Decrypt with:
    ```sh
    ansible-vault decrypt ssh/id_rsa_tomatoes
    ```
  - Use for SSH/SCP operations to any router referenced in the documentation.

- `id_dropbear_vhost`: Private key used by the `reverse-ssh-tunnel.sh` script on the `owrt3` router to establish a reverse SSH tunnel to a remote host.
  - Store this key securely on the router (`/root/.ssh/id_dropbear_vhost`).

**Do not commit decrypted private keys to the repository.**

## Public Keys
- `id_dropbear_vhost.pub`: Public key corresponding to `id_dropbear_vhost`.
  - This key must be added to the `authorized_keys` on the remote host specified in the `reverse-ssh-tunnel.sh` script (see `REMOTE_HOST` and `REMOTE_USER` in that script).
  - This allows the `owrt3` router to authenticate and establish the reverse SSH tunnel.

## Router Authorized Keys
- The `authorized_keys` file for each router is stored in the repository (e.g., `common/etc/dropbear/authorized_keys`).
  - Contains the public key for `id_rsa_tomatoes`.
  - Encrypted with Ansible Vault and managed using git filters for automatic encryption/decryption.
  - After decryption, deploy to the router for key-based authentication.

## Sensitive File Management
- All sensitive files are encrypted with Ansible Vault and managed using git filters for automatic encryption/decryption.
- See `docs/SENSITIVE.md` for details.
