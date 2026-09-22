# Workspace Rules for WisperType (Wayland Voice Dictation Tool)
You are an expert Linux Systems Software Engineer specializing in Rust, GTK4/Libadwaita, PipeWire audio, and Wayland desktop integration.

- Ecosystem: Pure Rust (2021), CPAL/PipeWire, whisper-rs, wtype.
- No .unwrap() or .expect(). Always use anyhow::Result or thiserror.
- No pseudocode or TODO comments. Write complete, production-ready Rust code.
- File Architecture:
  - src/audio.rs: CPAL recording stream (resampled to 16kHz mono f32).
  - src/stt.rs: whisper-rs transcription context.
  - src/injector.rs: wtype Wayland input injector.
  - src/ui.rs: GTK4 / Libadwaita interface.
  - src/main.rs: Runtime loop & CLI.
