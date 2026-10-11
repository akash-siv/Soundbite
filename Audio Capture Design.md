# Audio Capture Design (Soundbite)

Design specification for the lightweight hotkey audio snippet capture system.
Engineering tags: `[Decided 2026-10-05]`, `[Measured]`, `[Source]`.

---

## 1. Problem Statement

On modern desktop environments:
- **Screenshots:** Pressing `Print Screen` captures what is visible on display and saves it to local disk and clipboard.
- **Text:** Pressing `Ctrl + C` captures selected text into clipboard history.
- **Audio:** No standard desktop "Print Screen for Audio" utility exists out of the box. Traditional DAWs (Audacity) and voice recorders (GNOME Sound Recorder) require manual GUI operation, file naming, and stop buttons, resulting in high friction.

**Goal `[Decided 2026-10-05]`:** Provide a zero-friction audio capture mechanism analogous to `Print Screen`, operating via keyboard shortcuts on Fedora Linux with KDE Plasma 6 and PipeWire.

---

## 2. Architecture & Decisions

### 2.1 Capture Mode
- **Retroactive vs Forward Capture `[Decided 2026-10-05]`:** User specified forward snippet capture only (toggle recording). Rolling retroactive buffer was discarded to minimize memory footprint and unnecessary background I/O.
- **Workflow:**
  1. Trigger hotkey $\rightarrow$ Audio capture starts immediately in background via `soundbite toggle <mode>`.
  2. A persistent desktop notification appears (*"🔴 Soundbite Recording"*). No start sound is played, so capture begins immediately and the cue is not recorded.
  3. User finishes talking or media passage ends.
  4. Trigger hotkey again $\rightarrow$ Background process terminates cleanly via `SIGINT`, file headers flush, audio finishes muxing.
  5. File saved to `~/Music/AudioCaptures/Soundbite_<Timestamp>_<Mode>.mp3`.
  6. Path copied to Wayland clipboard (`wl-copy`).
  7. Sound cue (`complete.oga`) plays and KDE notification displays (*"✅ Soundbite Saved"*) with interactive buttons.

### 2.2 Audio Routing via PipeWire `[Measured 2026-10-05]`
Direct tests confirmed dynamic routing compatibility on Fedora 43 (PipeWire 1.6.8, FFmpeg 8.1.2):
- **Desktop Loopback:** Target `@DEFAULT_SINK@.monitor` captures all system outputs (YouTube, media players, calls).
- **Microphone Stream:** Target `@DEFAULT_SOURCE@` captures the primary input microphone.
- **Mixed Capture:** FFmpeg `amix=inputs=2:duration=longest:normalize=0` (followed by a limiter) combines monitor + mic into a synchronized stereo mix.
- **Dynamic Adaptability:** Using `@DEFAULT_SINK@.monitor` and `@DEFAULT_SOURCE@` ensures that unplugging or changing audio devices (Bluetooth, USB headsets) requires no script changes.

### 2.3 Process Management
- **State File `[Decided 2026-10-05]`:** Stored in `$XDG_RUNTIME_DIR/soundbite/recording.state`.
- **Termination Signal:** Sent via `kill -INT $PID`. Measured to allow `libmp3lame` and FFmpeg muxers to finalize ID3 tags and stream frames cleanly without corruption.
- **Detached Execution:** Background process spawned with `nohup` to guarantee survival across subshell lifecycles.
- **Fallback / Cancel:** `soundbite cancel` sends `SIGKILL` and deletes the incomplete file.

---

## 3. Component Specification

| Component | Technology | Rationale |
| :--- | :--- | :--- |
| **CLI / Controller** | Bash (`bin/soundbite`, alias `bin/audio-capture`) | Zero startup overhead, direct process management, native signal handling. |
| **Audio Backend** | PipeWire Pulse compatibility layer (`pulse`) | Native to Fedora; zero host clutter. |
| **Audio Encoder** | FFmpeg (`libmp3lame`, 192k) | Universally playable MP3 output with low encoding latency. |
| **Notifications** | `notify-send` (libnotify) | Standard freedesktop notification protocol, native KDE Plasma styling. |
| **Sound Cues** | `canberra-gtk-play` | Low-latency system audio cues (`freedesktop` sound theme). |
| **Clipboard** | `wl-copy` | Wayland clipboard integration. |
| **Shortcuts** | KDE Plasma 6 Shortcuts (`.desktop` / custom command) | Global Wayland hotkey support. |

---

## 4. Verification & Test Results `[Measured 2026-10-05]`

1. **Desktop Audio Capture:** Successfully captured loopback monitor output with 0 packet drops; output file verified valid MP3 via `ffprobe`.
2. **Microphone Capture:** Successfully captured ALSA analog stereo mic input stream.
3. **Mixed Capture:** Both streams mixed cleanly into stereo track via `amix`.
4. **Clipboard Integration:** Verified `wl-copy` registers path, pasteable via `wl-paste` immediately after stop.
5. **KDE Action Notification:** Non-blocking background notification tested with `Open Folder` (`xdg-open`) and `Play Audio` actions.
6. **Naming & Branding:** Tested `Soundbite_YYYY-MM-DD_HH-MM-SS_<mode>.mp3` generation; verified file creation and clean termination.
