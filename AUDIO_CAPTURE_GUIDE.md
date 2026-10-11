# Soundbite User Guide

A lightweight, hotkey-driven audio capture utility for Fedora Linux, PipeWire, and KDE Plasma 6.

Analogous to pressing **Print Screen** for screenshots or `Ctrl+C` for text, **Soundbite** allows you to instantly capture audio snippets (system sound, microphone, or both) and saves them locally while copying the file path to your clipboard.

---

## 1. Quick Start

### Test from Terminal
You can test recording directly from the command line:

```bash
# Capture Desktop Audio (what you hear through headphones/speakers):
soundbite toggle desktop

# Wait a few seconds, then run it again to finish:
soundbite toggle desktop
```

When recording stops:
1. The audio file is saved in `~/Music/AudioCaptures/Soundbite_YYYY-MM-DD_HH-MM-SS_desktop.mp3`.
2. The clip is automatically copied to your clipboard (`wl-copy`) as a file, or as its path with `CLIPBOARD_MODE="path"`.
3. A KDE notification appears with **"Open Folder"** and **"Play Audio"** action buttons.
4. A tactile sound cue plays on start (`camera-shutter`) and stop (`complete`).

---

## 2. Setting Up Shortcuts in KDE Plasma 6

To trigger recording instantly with global hotkeys:

1. Open **System Settings** in Fedora / KDE.
2. Navigate to **Keyboard** $\rightarrow$ **Shortcuts**.
3. Search for **Soundbite** or click **Add New** $\rightarrow$ **Application**.
4. Configure the three shortcuts:

| Name | Command | Recommended Shortcut | What it Captures |
| :--- | :--- | :--- | :--- |
| **Soundbite: Desktop Audio** | `soundbite toggle desktop` | `Meta + Shift + C` | YouTube, Spotify, browser sound, calls, games |
| **Soundbite: Microphone** | `soundbite toggle mic` | `Meta + Shift + V` | Voice memos, speaking ideas out loud |
| **Soundbite: Desktop + Mic** | `soundbite toggle both` | `Meta + Shift + B` | Both desktop audio and your microphone mixed |

5. Click **Apply**.

> **How it feels in practice:**
> Hit `Meta+Shift+C` $\rightarrow$ audio shutter click sounds $\rightarrow$ notification appears $\rightarrow$ when the segment ends, hit `Meta+Shift+C` again $\rightarrow$ chime sounds $\rightarrow$ audio is saved to disk and path is in your clipboard ready to paste.

---

## 3. CLI Commands Reference

| Command | Description |
| :--- | :--- |
| `soundbite toggle [desktop\|mic\|both]` | Starts recording if idle; stops and saves if recording. Default: `desktop`. |
| `soundbite start [desktop\|mic\|both]` | Starts recording immediately. |
| `soundbite stop` | Stops the current recording, encodes the final file, copies path, and notifies. |
| `soundbite cancel` | Aborts current recording immediately and deletes the temporary file. |
| `soundbite status` | Prints whether a recording is running, the active mode, PID, and elapsed time. |

*(Note: `audio-capture` is maintained as a direct symlink alias for backwards compatibility).*

---

## 4. Audio Streams & PipeWire Integration

This tool interfaces dynamically with PipeWire:
* **Desktop Audio (`desktop`):** Uses `@DEFAULT_SINK@.monitor`. When you switch from laptop speakers to USB headphones or Bluetooth, PipeWire automatically routes the active output to the capture stream without reconfiguration.
* **Microphone (`mic`):** Uses `@DEFAULT_SOURCE@`. Always routes your active system microphone.
* **Mixed Audio (`both`):** Captures `@DEFAULT_SINK@.monitor` and `@DEFAULT_SOURCE@` in parallel, passing them through `ffmpeg`'s `amix=inputs=2:duration=longest:normalize=0` filter and a limiter to generate a single stereo audio track.

---

## 5. Configuration (Optional)

You can customize directories, file prefix, audio quality, and formats by creating `~/.config/soundbite/config.env`:

```bash
mkdir -p ~/.config/soundbite
cat << 'EOF' > ~/.config/soundbite/config.env
# Target folder for saved audio clips
AUDIO_CAPTURE_DIR="$HOME/Music/AudioCaptures"

# Filename prefix (default: Soundbite)
AUDIO_FILE_PREFIX="Soundbite"

# Audio format: mp3 (default), wav, flac, opus, ogg, m4a, aac
AUDIO_FORMAT="mp3"

# Bitrate for compressed formats
AUDIO_BITRATE="192k"

# Audio cues & visual notifications (true / false)
PLAY_SOUNDS="true"
SEND_NOTIFICATIONS="true"
COPY_TO_CLIPBOARD="true"

# Clipboard content: "file" (default) or "path"
CLIPBOARD_MODE="file"
EOF
```

---

## 6. Troubleshooting

| Issue | Cause | Solution |
| :--- | :--- | :--- |
| Recording doesn't start | `ffmpeg` missing or it failed to open the audio device | Read the reason in the failure notification, or see `$XDG_RUNTIME_DIR/soundbite/ffmpeg.log`. |
| No desktop audio heard in clip | System audio was muted during capture | Ensure media is playing through the active default sink (`wpctl status`). |
| Clipboard path not pasted | Wayland clipboard manager issue | Check `wl-paste` in a terminal to confirm the path was copied. |
| Stray recording stuck in background | Unexpected reboot or kill | Run `soundbite stop` or `soundbite cancel`. |
