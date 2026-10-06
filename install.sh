#!/usr/bin/env bash
# ==============================================================================
# install.sh: Install Soundbite to ~/.local/bin and register KDE desktop entries
# [Decided 2026-10-05]
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_SOURCE="$SCRIPT_DIR/bin/soundbite"
TARGET_BIN="$HOME/.local/bin/soundbite"
COMPAT_BIN="$HOME/.local/bin/audio-capture"
APPS_DIR="$HOME/.local/share/applications"

echo "=== Installing Soundbite ==="

# Check dependencies
echo "Checking system tools..."
MISSING=0
for cmd in ffmpeg pactl wl-copy notify-send; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "  [!] Missing tool: $cmd"
        MISSING=1
    else
        echo "  [✓] Found: $cmd"
    fi
done

if (( MISSING == 1 )); then
    echo "Please install missing dependencies first."
    exit 1
fi

# 1. Symlink executable
mkdir -p "$HOME/.local/bin"
chmod +x "$BIN_SOURCE"
ln -sf "$BIN_SOURCE" "$TARGET_BIN"
ln -sf "$TARGET_BIN" "$COMPAT_BIN"
echo "[✓] Symlinked $BIN_SOURCE -> $TARGET_BIN"
echo "[✓] Symlinked compatibility alias -> $COMPAT_BIN"

# 2. Clean old shortcuts & install new application entries
mkdir -p "$APPS_DIR"
rm -f "$APPS_DIR/audio-capture-*.desktop"

for desktop_file in "$SCRIPT_DIR/shortcuts/"soundbite-*.desktop; do
    if [[ -f "$desktop_file" ]]; then
        fname="$(basename "$desktop_file")"
        cp "$desktop_file" "$APPS_DIR/$fname"
        echo "[✓] Installed application entry: $fname"
    fi
done

if command -v update-desktop-database &>/dev/null; then
    update-desktop-database "$APPS_DIR" &>/dev/null || true
fi

echo ""
echo "=== Installation Complete ==="
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
