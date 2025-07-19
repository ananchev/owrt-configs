# My OpenWrt

This repository manages OpenWrt UCI configuration files for multiple routers, separating common/shared configs from device-specific ones. Sensitive data (like Wi-Fi passwords and SSH keys) is encrypted and never stored in plain text. See `docs/SENSITIVE.md` for details on sensitive information management.

---

## Documentation

- [docs/SETUP.md](docs/SETUP.md): First-time setup, git filters, encryption/decryption
- [docs/CONFIG.md](docs/CONFIG.md): Configuration files reference and clarifications
- [docs/DEPLOY.md](docs/DEPLOY.md): Deployment steps, merge, SCP, router commands
- [docs/NOTES.md](docs/NOTES.md): Tips, troubleshooting, and miscellaneous info
- [docs/SENSITIVE.md](docs/SENSITIVE.md): Sensitive information management

---

### Repository Structure

```
owrt-configs/
├── common/
│   ├── <shared-config-files>
│   └── ...
├── owrt/
│   ├── etc/
│   │   ├── config/
│   │   │   ├── <symlink-to-shared-config>   # symlink to common/<shared-config-files>
│   │   │   ├── <device-specific-config>
│   │   │   └── ...
├── owrt2/
│   ├── etc/
│   │   ├── config/
│   │   │   ├── <symlink-to-shared-config>   # symlink to common/<shared-config-files>
│   │   │   ├── <device-specific-config>
│   │   │   └── ...
└── docs/
    ├── <documentation-files>
    └── ...
```

- `<shared-config-files>`: All configs shared between devices.
- `<symlink-to-shared-config>`: Symlinks in device folders pointing to shared configs.
- `<device-specific-config>`: Configs unique to each device.
- `<documentation-files>`: All documentation.

