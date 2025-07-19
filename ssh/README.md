# SSH Key for Router Access

This folder contains an AES256-encrypted private SSH key (`id_rsa_tomatoes`) used for key-based authentication to all managed OpenWrt routers.

- The key is encrypted using Ansible Vault with the password labeled: **Ansible vault for home infrastructure**.
- To use this key, decrypt it with:
  ```sh
  ansible-vault decrypt ssh/id_rsa_tomatoes
  ```
- After decryption, use this key for SSH and SCP operations to any router referenced in the documentation.

**Do not commit the decrypted key to the repository.**

---

## Router Authorized Keys

The `authorized_keys` file for each router is also stored in the repository (e.g., `common/etc/dropbear/authorized_keys`).
- This file contains the public key corresponding to `id_rsa_tomatoes`.
- AIt is encrypted with Ansible Vault and managed using the git filters approach for automatic encryption/decryption.
- After decryption, deploy it to the router for key-based authentication.
