# Tips, Troubleshooting, and Miscellaneous

- The `-O` flag forces `scp` to use the legacy SCP protocol, required for Dropbear (the default OpenWrt SSH server).
- Always review changes before deploying to avoid misconfiguration.
- After copying, you may need to reload configuration or reboot the router:
  ```sh
  ssh -i ~/.ssh/id_rsa_tomatoes root@owrt 'reload_config'
  ssh -i ~/.ssh/id_rsa_tomatoes root@owrt2 'reload_config'
  ```
- If git filters do not decrypt files, check that `decrypt.sh` and `encrypt.sh` are present and executable, and that your `.git/config` and `.gitattributes` are correct.
- If all else fails, manually decrypt with Ansible Vault.
- For more details on configuration files, see `CONFIG.md`.
- For deployment steps, see `DEPLOY.md`.
- For setup instructions, see `SETUP.md`.
