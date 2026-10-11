# Soundbite (13 Audio Capture)

> **OS Platform Target:** Designed and tested exclusively on **Fedora Linux** (Fedora 40/41+ with PipeWire, KDE Plasma 6, and Wayland).

**Soundbite** is a lightweight, zero-daemon, hotkey-driven audio snippet capture tool for Fedora Linux.

Just like pressing **Print Screen** captures a screenshot to your disk and clipboard, or pressing `Ctrl + C` copies text, **Soundbite** gives you an instant, friction-free way to capture audio snippets (system audio, microphone, or both mixed) on demand.

---

## Table of Contents
1. [What This Project Is For](#what-this-project-is-for)
2. [What This Application Is For](#what-this-application-is-for)
3. [Platform Compatibility & Requirements](#platform-compatibility--requirements)
4. [How to Install](#how-to-install)
5. [How to Set Up Desktop Shortcuts in Fedora (KDE Plasma 6)](#how-to-set-up-desktop-shortcuts-in-fedora-kde-plasma-6)
6. [How to Use (CLI & Shortcuts)](#how-to-use-cli--shortcuts)
7. [How to Configure](#how-to-configure)
8. [How to Change Anything (Customization Guide)](#how-to-change-anything-customization-guide)
9. [Directory Structure](#directory-structure)
10. [Troubleshooting & Verification](#troubleshooting--verification)

---

## What This Project Is For

In modern desktop workflows, taking a screenshot or copying text takes less than a second. However, capturing a quick 10-second snippet of audio—such as:
* An interesting excerpt from a podcast, YouTube video, or webinar
* A quick voice memo, dictation, or thought while working
* A snippet from a meeting, VoIP call, or system sound

...traditionally requires opening heavy, complex software like Audacity or OBS Studio, configuring audio tracks, hitting record, manually trimming, and exporting. 

**This project exists to eliminate that friction completely.** It provides a native, minimalist UNIX-style tool that runs entirely on system utilities already present on Fedora, requiring zero memory when not actively recording.

---

## What This Application Is For

**Soundbite** is the executable utility that orchestrates the capture workflow:
* **Instant Toggle Recording:** Tap a shortcut once to start; tap again to stop and finalize.
* **Three Flexible Capture Modes:**
  1. **Desktop Audio (`desktop`):** Captures what you hear through your headphones or speakers (`@DEFAULT_SINK@.monitor`).
  2. **Microphone (`mic`):** Captures voice input from your default system microphone (`@DEFAULT_SOURCE@`).
  3. **Mixed Audio (`both`):** Captures both desktop audio and your microphone simultaneously, mixed cleanly into a single stereo track via FFmpeg.
* **Smart File Naming:** Automatically generates unique, chronologically sortable filenames:
  ```text
  Soundbite_YYYY-MM-DD_HH-MM-SS_<mode>.mp3
  ```
  *(e.g., `~/Music/AudioCaptures/Soundbite_2026-10-05_20-13-44_desktop.mp3`)*
* **Automatic Clipboard Integration:** Instantly copies the full path of the saved file to your Wayland clipboard (`wl-copy`), ready to paste (`Ctrl + V`) into a terminal, chat, or script.
* **Tactile Audio & Visual Feedback:**
  * Plays a `camera-shutter` audio cue when recording begins.
  * Plays a `complete` chime cue when recording stops.
  * Displays a non-intrusive desktop notification with interactive **"Open Folder"** and **"Play Audio"** action buttons.
* **Zero Host Clutter:** No persistent background daemons, services, or Electron bloat. When idle, CPU and RAM usage is strictly 0%.

---

## Platform Compatibility & Requirements

> [!IMPORTANT]
> **Fedora Linux Only:** This application is specifically designed for and tested on **Fedora Linux** (tested on Fedora 40/41+ running PipeWire audio server and KDE Plasma 6 under Wayland). Other distributions (Ubuntu, Arch, etc.) or display servers (X11) may require manual adjustments for audio sink names and clipboard utilities.

### System Dependencies
Soundbite relies on Fedora's standard multimedia and desktop tools:
* `ffmpeg` (audio encoder and multiplexer)
* `pipewire` & `pipewire-pulseaudio` (modern audio routing via Pulse compatibility layer)
* `wl-clipboard` (`wl-copy` for Wayland clipboard support)
* `libnotify` (`notify-send` for desktop notifications)
* `libcanberra-gtk3` (`canberra-gtk-play` for low-latency system sound cues)

To install all dependencies on Fedora:
```bash
sudo dnf install -y ffmpeg pipewire-pulseaudio wl-clipboard libnotify libcanberra-gtk3
```

---

## How to Install

Run the automated installer script included in this repository:

```bash
# From the root of this repository
./install.sh

# Or choose a different install folder
./install.sh "$HOME/Apps/Soundbite"
```

### What the installer does:
1. Verifies that `ffmpeg` is installed, and reports which optional tools (`wl-copy`, `notify-send`, `canberra-gtk-play`, `flock`) are available.
2. Copies the application into the install folder (default: `~/Apps-Appimage/Soundbite/`). The installed copy does not depend on this repository, so the repository can be moved or archived afterwards.
3. Creates a symlink from `~/.local/bin/soundbite` to the installed copy (and maintains `~/.local/bin/audio-capture` as a compatibility alias).
4. Installs KDE application entries into `~/.local/share/applications/`, with `Exec=` pointing at the installed copy by absolute path, and removes the legacy `audio-capture-*.desktop` entries.
5. Refreshes the desktop application database via `update-desktop-database`.

After changing anything in this repository, run `./install.sh` again to update the installed copy.

---

## How to Set Up Desktop Shortcuts in Fedora (KDE Plasma 6)

After running `./install.sh`, you can bind Soundbite to global hotkeys in Fedora's KDE Plasma 6:

1. Open **System Settings** in Fedora.
2. In the left sidebar, navigate to **Keyboard** $\rightarrow$ **Shortcuts**.
3. Under the **Applications** list, search for **Soundbite**. You will see three entries:
   * **Soundbite: Desktop Audio**
   * **Soundbite: Microphone**
   * **Soundbite: Desktop + Mic**
4. Click on each action and assign your preferred global shortcut:
   | Action | Recommended Shortcut | Description |
   | :--- | :--- | :--- |
   | **Soundbite: Desktop Audio** | `Meta + Shift + A` | Captures YouTube, Spotify, browser sound, calls |
   | **Soundbite: Microphone** | `Meta + Shift + V` | Captures quick voice memos and spoken thoughts |
   | **Soundbite: Desktop + Mic** | `Meta + Shift + B` | Captures both system audio and your microphone |
5. Click **Apply** in the bottom right corner of System Settings.

> **How it works in practice:**
> 1. Press `Meta + Shift + A` $\rightarrow$ You hear a subtle shutter click and see a notification confirming recording started.
> 2. Let the audio play (or speak into your mic).
> 3. Press `Meta + Shift + A` again $\rightarrow$ A chime sounds, the MP3 is saved in `~/Music/AudioCaptures/`, and the file path is copied to your clipboard ready to paste!

---

## How to Use (CLI & Shortcuts)

You can run Soundbite directly from your terminal or scripts:

### Starting / Toggling
```bash
# Toggle desktop recording (start if idle; stop if active)
soundbite toggle desktop

# Toggle microphone recording
soundbite toggle mic

# Toggle combined desktop + microphone recording
soundbite toggle both
```

### Explicit Controls
```bash
# Explicitly start recording
soundbite start desktop

# Stop recording and finalize audio file
soundbite stop

# Cancel recording and discard temporary audio file
soundbite cancel

# Inspect active status, PID, mode, and elapsed time
soundbite status
```

*(Note: `audio-capture` works identically as a backwards-compatible alias).*

---

## How to Configure

Soundbite works immediately with sensible defaults, but you can customize any behavior by creating an environment configuration file:

```bash
mkdir -p ~/.config/soundbite
cat << 'EOF' > ~/.config/soundbite/config.env
# Target storage folder for saved clips
AUDIO_CAPTURE_DIR="$HOME/Music/AudioCaptures"

# Filename prefix (default: Soundbite)
AUDIO_FILE_PREFIX="Soundbite"

# Output audio format: mp3 (default), wav, flac, opus, ogg, m4a, aac
AUDIO_FORMAT="mp3"

# Audio bitrate for compressed formats (e.g. 192k, 256k, 320k)
AUDIO_BITRATE="192k"

# Sound cues on start and stop (true / false)
PLAY_SOUNDS="true"

# Desktop notifications (true / false)
SEND_NOTIFICATIONS="true"

# Copy file path to Wayland clipboard automatically (true / false)
COPY_TO_CLIPBOARD="true"
EOF
```

---

## How to Change Anything (Customization Guide)

### 1. Changing the Filename Prefix
By default, files begin with `Soundbite_`. To change this:
* Open `~/.config/soundbite/config.env` and set:
  ```bash
  AUDIO_FILE_PREFIX="Memo"
  ```
  Result: `Memo_2026-10-05_20-13-44_desktop.mp3`.

### 2. Changing the Save Folder
By default, files are saved to `~/Music/AudioCaptures/`. To change to another location (e.g., your Desktop or a custom Recordings directory):
* In `~/.config/soundbite/config.env`:
  ```bash
  AUDIO_CAPTURE_DIR="$HOME/Recordings/Audio"
  ```

### 3. Switching to Lossless Audio (FLAC or WAV)
If you require studio-grade lossless capture:
* In `~/.config/soundbite/config.env`:
  ```bash
  AUDIO_FORMAT="flac"
  # or
  AUDIO_FORMAT="wav"
  ```

### 4. Changing Clipboard Behavior (File Object vs. Path String)
* **Default (`text/plain`):** Copies the path string (`/home/.../Soundbite_...mp3`), ideal for terminals and bash scripts.
* **File Object Mode (`text/uri-list`):** If you prefer pressing `Ctrl + V` in file managers (Dolphin) or chat apps (Discord/Slack) to paste the actual file instead of its path, replace the `wl-copy` line in the "Clipboard copy" block of `bin/soundbite` (then run `./install.sh` again):
  ```bash
  printf "file://%s\r\n" "$OUTFILE" | wl-copy -t text/uri-list 2>/dev/null || true
  ```

### 5. Modifying Shortcut Definitions
The desktop shortcut definitions reside in `shortcuts/`:
* `shortcuts/soundbite-desktop.desktop`
* `shortcuts/soundbite-mic.desktop`
* `shortcuts/soundbite-both.desktop`
If you modify these files, run `./install.sh` again to update your desktop system entries.

---

## Directory Structure

```
13 Audio Capture/
├── README.md                      ← Complete documentation and quickstart (this file)
├── AUDIO_CAPTURE_GUIDE.md         ← User guide, shortcuts reference & troubleshooting
├── Audio Capture Design.md        ← Technical architecture, PipeWire routing & benchmarks
├── LICENSE                        ← MIT License
├── install.sh                     ← Fedora installer script (copies the app, links the binary & shortcuts)
├── bin/
│   ├── soundbite                  ← Main executable controller script
│   └── audio-capture              ← Backwards-compatible symlink to soundbite
└── shortcuts/                     ← KDE Plasma 6 desktop application shortcuts
    ├── soundbite-desktop.desktop  ← Desktop audio capture entry
    ├── soundbite-mic.desktop      ← Microphone capture entry
    └── soundbite-both.desktop     ← Mixed capture entry
```

---

## Troubleshooting & Verification

| Issue | Cause | Solution |
| :--- | :--- | :--- |
| **Command not found** | `~/.local/bin` is not in your `$PATH` | Add `export PATH="$HOME/.local/bin:$PATH"` to your `~/.bashrc` and restart terminal. |
| **No audio recorded (silence)** | Default audio device was muted or inactive | Ensure media is playing and verify active sink via `wpctl status`. |
| **Clipboard path not copied** | Wayland compositor or `wl-clipboard` issue | Verify `wl-paste` outputs the path; check if `wl-clipboard` package is installed. |
| **Recording stuck in background** | Process was orphaned or subshell killed | Run `soundbite stop` or `soundbite cancel` to cleanly reset state. |
| **"Soundbite Failed" notification** | `ffmpeg` could not start or wrote no audio | Read the reason in the notification, or see `$XDG_RUNTIME_DIR/soundbite/ffmpeg.log`. |
| **Shortcut does nothing** | Installed copy is missing or outdated | Run `./install.sh` again from this repository. |
| **Audio shutter sound missing** | `libcanberra-gtk3` sound theme not found | Run `sudo dnf install libcanberra-gtk3 sound-theme-freedesktop`. |
