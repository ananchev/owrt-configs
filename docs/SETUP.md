# First-Time Setup & Git Filters

This guide covers the initial setup for working with this repository, including handling encrypted files using Ansible Vault and Git filters.

## Initial Clone & Decryption

1. Clone the repository:
   ```sh
   git clone git@github.com:ananchev/owrt-configs.git
   cd owrt-configs
   ```
2. Make filter scripts executable:
   ```sh
   chmod +x decrypt.sh encrypt.sh
   ```
3. Check out all files:
   ```sh
   git checkout HEAD -- .
   ```

If any sensitive file (e.g., `common/etc/config/wireless.key`, `ssh/id_rsa_tomatoes`, `common/etc/dropbear/authorized_keys`) is still encrypted after checkout, manually decrypt it:
```sh
ansible-vault decrypt <file>
```
Enter the vault password when prompted. This will overwrite the file with the decrypted content.

## Git Filter Configuration

- `.gitattributes` should contain:
  ```
  common/etc/config/wireless.key filter=ansible-vault
  ssh/id_rsa_tomatoes filter=ansible-vault
  common/etc/dropbear/authorized_keys filter=ansible-vault
  ```
- Add to your local `.git/config`:
  ```ini
  [filter "ansible-vault"]
      clean = ./encrypt.sh
      smudge = ./decrypt.sh
  ```

## Ansible Vault Usage
- To encrypt: `ansible-vault encrypt <file>`
- To decrypt: `ansible-vault decrypt <file>`

See `NOTES.md` for troubleshooting tips.
