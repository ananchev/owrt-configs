# Configuration Files Reference

This file describes the configuration files managed in this repository and their purpose.

## Common Files
- `wireless.main`: Non-sensitive wireless configuration (SSID, channel, etc.)
- `wireless.key`: Contains only Wi-Fi password line(s), encrypted before commit
- `wireless`: Merged file for deployment, ignored by git
- `dropbear/authorized_keys`: Public keys for SSH access to routers, encrypted before commit

## Device-Specific Files
- `owrt/` and `owrt2/`: Device-specific configs override common files

For details on sensitive information management and wireless file handling, see `docs/SENSITIVE.md`.

All files are now located under `common/etc/config/` and `owrt/etc/config/`, `owrt2/etc/config/`.

See `DEPLOY.md` for deployment instructions.
