#!/usr/bin/env bash
# ==============================================================================
# install.sh: Copy Soundbite into an install folder, link it into ~/.local/bin
# and register KDE desktop entries
# [Decided 2026-10-05]
#
# Usage: ./install.sh [install-dir]   (default: ~/Apps-Appimage/Soundbite)
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${1:-${SOUNDBITE_INSTALL_DIR:-$HOME/Apps-Appimage/Soundbite}}"
INSTALLED_BIN="$INSTALL_DIR/bin/soundbite"
TARGET_BIN="$HOME/.local/bin/soundbite"
COMPAT_BIN="$HOME/.local/bin/audio-capture"
APPS_DIR="$HOME/.local/share/applications"

echo "=== Installing Soundbite ==="

# Check dependencies
echo "Checking system tools..."
if ! command -v ffmpeg &>/dev/null; then
    echo "  [!] Missing required tool: ffmpeg"
    echo "Please install missing dependencies first."
    exit 1
fi
echo "  [✓] Found: ffmpeg"

for cmd in wl-copy notify-send canberra-gtk-play flock; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "  [!] Optional tool not found: $cmd (that feature will be skipped)"
    else
        echo "  [✓] Found: $cmd"
    fi
done

# 1. Copy the application into the install folder
# The installed copy is independent of this repository, so moving or archiving
# the repository does not break the command or the shortcuts.
mkdir -p "$INSTALL_DIR/bin" "$INSTALL_DIR/shortcuts"
install -m 755 "$SCRIPT_DIR/bin/soundbite" "$INSTALLED_BIN"
ln -sfn soundbite "$INSTALL_DIR/bin/audio-capture"
for doc in README.md AUDIO_CAPTURE_GUIDE.md LICENSE; do
    install -m 644 "$SCRIPT_DIR/$doc" "$INSTALL_DIR/$doc"
done
echo "[✓] Copied application to $INSTALL_DIR"

# 2. Symlink executable
mkdir -p "$HOME/.local/bin"
ln -sfn "$INSTALLED_BIN" "$TARGET_BIN"
ln -sfn "$TARGET_BIN" "$COMPAT_BIN"
echo "[✓] Symlinked $TARGET_BIN -> $INSTALLED_BIN"
echo "[✓] Symlinked compatibility alias -> $COMPAT_BIN"

# 3. Clean old shortcuts & install new application entries
mkdir -p "$APPS_DIR"
rm -f "$APPS_DIR"/audio-capture-*.desktop

# Exec uses the absolute installed path so shortcuts do not depend on $PATH
exec_path="${INSTALLED_BIN//\\/\\\\}"
exec_path="${exec_path//&/\\&}"
for desktop_file in "$SCRIPT_DIR/shortcuts/"soundbite-*.desktop; do
    if [[ -f "$desktop_file" ]]; then
        fname="$(basename "$desktop_file")"
        sed "s|^Exec=soundbite |Exec=\"$exec_path\" |" "$desktop_file" > "$INSTALL_DIR/shortcuts/$fname"
        install -m 644 "$INSTALL_DIR/shortcuts/$fname" "$APPS_DIR/$fname"
        echo "[✓] Installed application entry: $fname"
    fi
done

if command -v update-desktop-database &>/dev/null; then
    update-desktop-database "$APPS_DIR" &>/dev/null || true
fi

echo ""
echo "=== Installation Complete ==="
echo "Installed to: $INSTALL_DIR"
echo "You can test it right now by running:"
echo "    soundbite toggle desktop"
echo ""
echo "To configure shortcuts in KDE Plasma 6:"
echo "  1. Open System Settings -> Keyboard -> Shortcuts."
echo "  2. Search for 'Soundbite' or click 'Add New' -> 'Application'."
echo "  3. Select:"
echo "     - 'Soundbite: Desktop Audio' -> assign shortcut (e.g., Meta + Shift + A)"
echo "     - 'Soundbite: Microphone'    -> assign shortcut (e.g., Meta + Shift + V)"
echo "     - 'Soundbite: Desktop + Mic' -> assign shortcut (e.g., Meta + Shift + B)"
echo "  4. Click Apply."
