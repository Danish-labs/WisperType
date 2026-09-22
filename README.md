Here is your complete, copy-and-paste ready `README.md` file. It includes all the technical specifications, setup instructions, architecture details, and project structure files you gathered, styled professionally with clean Markdown formatting and badges.

```markdown
<div align="center">

# 🎙️ WhisperType

**A lightweight, local-first speech-to-text dictation tool for Arch Linux desktops.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Arch Linux](https://img.shields.io/badge/Arch%20Linux-Supported-1793D1?logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Language: Rust](https://img.shields.io/badge/Language-Rust-orange?logo=rust&logoColor=white)](https://www.rust-lang.org/)

</div>

---

## ✨ Overview

**WhisperType** is a lightweight Linux speech-to-text dictation app for offline local transcription. It captures audio from the default microphone, sends the audio to a local Whisper-compatible inference endpoint, and then injects the recognized text into the active application using keyboard input simulation.

This project is designed for users who want private, local dictation on Arch and Linux desktops without depending on external cloud AI services.

### Key Use Cases
* Local dictation and accessibility workflows
* Quick voice typing
* Privacy-focused desktop use

---

## 🛠️ Tech Stack

* **Language:** Rust
* **Async Runtime:** Tokio
* **Audio Capture:** CPAL (`cpal`)
* **HTTP Requests:** Reqwest (`reqwest`)
* **Audio Encoding:** Hound (`hound`)
* **Text Injection:** `wtype`
* **Packaging:** Arch Linux packaging via `PKGBUILD` / AUR
* **Automation:** systemd user service (`wispertype.service`)
* **Model:** Local Whisper model file (`ggml-tiny.en.bin`)

---

## 🔄 How It Works

```mermaid
graph TD
    A[Microphone Audio (CPAL)] -->|16kHz Mono WAV| B[Local Whisper Backend]
    B -->|Recognized Text| C[Text Injection (wtype)]
    C -->|Active Window| D[Typed on Screen]

```

1. The app starts and initializes the transcription client.
2. Audio is captured from the default input device using CPAL.
3. The captured data is normalized to 16 kHz mono audio.
4. The audio is encoded as WAV so it can be sent to a Whisper endpoint.
5. A multipart HTTP request is sent to: `http://127.0.0.1:8080/inference`
6. The local Whisper service returns the recognized text.
7. The result is injected into the focused app with `wtype`.

---

## 📂 Project Structure

* `src/main.rs` — app entry point
* `src/audio.rs` — microphone capture and buffer handling
* `src/stt.rs` — Whisper client and WAV upload logic
* `src/injector.rs` — text injection via `wtype`
* `PKGBUILD` — Arch package recipe
* `install-model.sh` — downloads the local model
* `wispertype.service` — user systemd service for startup
* `wispertype.desktop` — desktop launcher
* `build.rs` — build-time setup

---

## 📦 Installation

### Arch / AUR-style install

Build the package locally from the repo:

```bash
makepkg -si

```

Or install via your preferred AUR helper:

```bash
yay -S wispertype

```

The package is designed to:

* Install the application binary
* Download the small Whisper model
* Enable startup via systemd user service
* Set up the desktop launcher

---

## ⚙️ Setup & Dependencies

### Required System Dependencies

Make sure your system has the following tools and packages installed:

* Rust toolchain (`cargo`, `rustc`)
* `curl`
* `pipewire` (or PulseAudio equivalent)
* `wtype`
* Build tools like `clang`, `cmake`, and standard build essentials

### Local Model Configuration

The project expects a small Whisper model file located at:

```bash
~/.local/share/wispertype/models/ggml-tiny.en.bin

```

This model is kept intentionally small for lower RAM usage and better desktop responsiveness.

---

## 📊 CPU and RAM Usage

### Typical Profile

* **Idle:** Very low CPU usage
* **During transcription:** Moderate CPU usage, depending on model size and hardware capabilities
* **RAM:** Low to moderate footprint

### Recommended Model Choice

* **`tiny` model:** Lowest memory footprint, fastest startup (Recommended default)
* **Larger models:** Better transcription accuracy, but higher memory and CPU utilization

For a lightweight desktop experience, the tiny English model is preferred.

---

## 🔒 Security and Privacy

The design is intentionally local-first:

* **No cloud API key** required
* **No external voice processing service** required
* **Transcription happens entirely** on the machine where the app runs

This architecture keeps your voice data completely private and reduces network dependence.

---

## ⚠️ Limitations

* Requires a working Wayland/X11 desktop session capable of keyboard injection (`wtype`)
* Depends on a valid local Whisper-compatible backend running locally
* Needs active microphone permissions and a usable audio input device
* Transcription accuracy depends on the local model size and available CPU power

---

## 📝 License

This project is released under the **MIT License**. See `LICENSE` for more details.

---

## 🤝 Contributing

Contributions are welcome! Please keep code simple, production-ready, and Linux-focused. The project favors:

* Small, efficient local processing
* Clean Rust code
* Arch-compatible packaging
* Minimal external dependencies

```

---

<Elicitations message="What would you like to do next?">
  <Elicitation label="Create PKGBUILD script" query="How do I write the PKGBUILD file for packaging WisperType for the AUR?"/>
  <Elicitation label="Create systemd service file" query="How do I write the wispertype.service file for startup automation?"/>
</Elicitations>

```
