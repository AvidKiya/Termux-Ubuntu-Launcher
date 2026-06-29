# Changelog

## 1.1.0 - 2026-06-29

- Installer now backs up and rewrites `~/.bashrc` from zero, as requested.
- Added fish compatibility hook for users whose Termux starts with fish.
- Fixed confusion around running `source ~/.bashrc` inside fish.
- Ubuntu installer now also patches PATH and installs the `patch` package.
- Ubuntu installer now installs common development packages for tools that need compiling.
- Ubuntu startup shell exports a safe Linux PATH.

## 1.0.0 - 2026-06-29

- Initial release
- Termux startup menu
- Ubuntu install/run support through proot-distro
- Termux and Ubuntu ASCII banners
- Weather report support
- Install and uninstall scripts
- Persian and English documentation
