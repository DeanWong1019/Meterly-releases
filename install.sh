#!/bin/sh
# Installs (or updates) Meterly from the latest GitHub release.
#
#   curl -fsSL https://raw.githubusercontent.com/DeanWong1019/Meterly-releases/main/install.sh | sh
#
# Optional environment:
#   VERSION=1.0.6      install a specific version instead of the latest
#   INSTALL_DIR=...    install somewhere other than /Applications
#   NO_OPEN=1          do not launch the app afterwards
set -eu

REPO="DeanWong1019/Meterly-releases"
APP_NAME="Meterly"
BUNDLE_ID="com.quotaflow.app"
INSTALL_DIR="${INSTALL_DIR:-/Applications}"

fail() { printf 'Error: %s\n' "$1" >&2; exit 1; }

[ "$(uname -s)" = "Darwin" ] || fail "Meterly is a macOS app."
[ "$(uname -m)" = "arm64" ] || fail "Meterly needs a Mac with Apple silicon (this one reports $(uname -m))."

if [ -n "${VERSION:-}" ]; then
  URL="https://github.com/$REPO/releases/download/v${VERSION#v}/$APP_NAME.zip"
else
  URL="https://github.com/$REPO/releases/latest/download/$APP_NAME.zip"
fi

[ -d "$INSTALL_DIR" ] && [ -w "$INSTALL_DIR" ] || fail "$INSTALL_DIR is not writable. Run again with sudo, or set INSTALL_DIR to a folder you own."

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

printf 'Downloading %s...\n' "$URL"
curl -fL --progress-bar -o "$WORK/$APP_NAME.zip" "$URL" || fail "Download failed. Check your connection and that the version exists."

ditto -x -k "$WORK/$APP_NAME.zip" "$WORK/extracted" || fail "Could not unpack the download."
NEW_APP="$WORK/extracted/$APP_NAME.app"
[ -d "$NEW_APP" ] || fail "The download does not contain $APP_NAME.app."
[ "$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "$NEW_APP/Contents/Info.plist" 2>/dev/null)" = "$BUNDLE_ID" ] \
  || fail "The download is not the expected app."
VERSION_INSTALLED="$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$NEW_APP/Contents/Info.plist")"

# Quit a running copy of the app being replaced (and only that one).
RUNNING_PATTERN="$INSTALL_DIR/$APP_NAME.app/Contents/MacOS/$APP_NAME"
if pgrep -f "$RUNNING_PATTERN" >/dev/null 2>&1; then
  printf 'Quitting the running %s...\n' "$APP_NAME"
  osascript -e "tell application \"$APP_NAME\" to quit" >/dev/null 2>&1 || true
  i=0
  while pgrep -f "$RUNNING_PATTERN" >/dev/null 2>&1 && [ "$i" -lt 20 ]; do sleep 0.5; i=$((i + 1)); done
  pgrep -f "$RUNNING_PATTERN" >/dev/null 2>&1 && pkill -f "$RUNNING_PATTERN" 2>/dev/null || true
fi

rm -rf "$INSTALL_DIR/$APP_NAME.app"
ditto "$NEW_APP" "$INSTALL_DIR/$APP_NAME.app"
# Files fetched with curl carry no quarantine flag; clear it anyway so
# Gatekeeper never blocks the first launch.
xattr -cr "$INSTALL_DIR/$APP_NAME.app" 2>/dev/null || true

printf 'Installed %s %s in %s\n' "$APP_NAME" "$VERSION_INSTALLED" "$INSTALL_DIR"
[ "${NO_OPEN:-0}" = "1" ] || open "$INSTALL_DIR/$APP_NAME.app"
