# Meterly

Packaged builds of Meterly, a macOS menu bar app for AI token usage, cost and quota. Source is private; this repository only hosts the releases the in-app updater reads.

## Install

Requires a Mac with Apple silicon.

```sh
curl -fsSL https://raw.githubusercontent.com/DeanWong1019/Meterly-releases/main/install.sh | sh
```

This downloads the latest release, puts `Meterly.app` in `/Applications`, clears the macOS quarantine flag and opens it. Meterly lives in the menu bar (no Dock icon). Running the same command again updates or reinstalls it.

Options (set before the command):

| Variable | Effect |
|---|---|
| `VERSION=1.0.6` | install a specific version instead of the latest |
| `INSTALL_DIR=$HOME/Applications` | install somewhere other than `/Applications` |
| `NO_OPEN=1` | do not launch the app afterwards |

Example: `curl -fsSL https://raw.githubusercontent.com/DeanWong1019/Meterly-releases/main/install.sh | VERSION=1.0.6 sh`

### Manual install

1. Download `Meterly.zip` from the [latest release](../../releases/latest) and unzip it.
2. Drag `Meterly.app` into Applications.
3. The app is not notarized, so on first launch right-click it and choose Open (or run `xattr -cr /Applications/Meterly.app` once).

## Updates

Meterly checks this repository in the background. When a newer version exists, an **Update** pill appears in the panel header; click it to download, install and restart. Automatic checks can be turned off in Settings.

## Uninstall

```sh
osascript -e 'tell application "Meterly" to quit'; rm -rf /Applications/Meterly.app
```
