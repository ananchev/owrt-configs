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

## Adding Sensitive Files to the Repo

Sensitive files (such as Wi-Fi keys, SSH keys, and authorized_keys) must always be initally added using the command line:
```sh
git add <file>
```
You will be prompted for your Ansible Vault password. This ensures the file is encrypted in the git index, while your local copy remains decrypted. **Do not use the VS Code UI to stage sensitive files, as it may bypass the encryption filter.**

## Git Filter Configuration (Required After Clone)

After cloning the repository, you must manually add the filter section to your local `.git/config`:
```ini
[filter "ansible-vault"]
    clean = ./encrypt.sh
    smudge = ./decrypt.sh
```
This enables automatic encryption/decryption for sensitive files listed in `.gitattributes`.

## Ansible Vault Usage
- To encrypt: `ansible-vault encrypt <file>`
- To decrypt: `ansible-vault decrypt <file>`

See `NOTES.md` for troubleshooting tips.
