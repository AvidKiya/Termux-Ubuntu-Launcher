# Changelog

## 2.3.0 - 2026-06-29

- Ubuntu now installs fish, Oh My Fish, and the batman theme too.
- Ubuntu option 2 shows the Avid Kiya Ubuntu banner and then opens fish/batman by default.
- Added Ubuntu fish PATH config so MiMo works inside fish as well.
- Added `AK_AUTO_FISH_AFTER_UBUNTU` config option.

## 2.2.0 - 2026-06-29

- Finalized matched Termux/Ubuntu Avid Kiya banners with lolcat color style.
- Installer now rewrites config from zero too, with backup, so old settings cannot break the final theme.
- Ubuntu patcher now adds `/root/.mimocode/bin` to PATH permanently.
- Ubuntu patcher now sources `/root/.bashrc` and symlinks `/root/.mimocode/bin/mimo` to `/usr/local/bin/mimo` when available.
- MiMo command-not-found fix is now built in.
- Ubuntu startup now sources `/root/.bashrc` before showing prompt.

## 2.1.0 - 2026-06-29

- Termux and Ubuntu banners now follow the same Avid Kiya style but with different artwork.
- Termux option uses Android art + TERMUX boxed banner + weather/date/uname.
- Ubuntu option uses penguin art + UBUNTU boxed banner + weather/date/uname and is colorized with lolcat when available.
- Ubuntu patcher now installs Node.js/npm, ruby/lolcat, development tools, and tries to install MiMo Code automatically.
- Added MiMo repair via `npm install -g @mimo-ai/cli` and official `curl -fsSL https://mimo.xiaomi.com/install | bash` fallback.

## 2.0.0 - 2026-06-29

- Rebased project around the original classic Avid Kiya Termux theme.
- Option 1 now runs the classic flow and opens fish by default.
- Installer now installs termux-api, termux storage setup, fish, Oh My Fish, and batman theme.
- Installer now includes python, git, ruby, curl, figlet, screenfetch, nano, lolcat.

## 1.2.0 - 2026-06-29

- Fixed Ubuntu detection by testing real `proot-distro login ubuntu -- /bin/true`.
- Option 3 now asks: Patch/Update, Reinstall, or Back when Ubuntu exists.
- Added repair flow for broken containers where install says container exists.
- Added responsive compact ASCII menu for narrow mobile terminals.
- Ubuntu option now starts only after a successful login test.

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
