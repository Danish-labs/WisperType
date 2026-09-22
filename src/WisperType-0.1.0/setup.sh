#!/bin/bash
set -e

echo "=== 1. Installing Arch Linux System Dependencies ==="
sudo pacman -S --needed base-devel rustup clang cmake wtype pipewire libadwaita git
rustup default stable

echo "=== 2. Downloading Local Whisper AI Model (~75MB) ==="
mkdir -p ~/.local/share/whispertype/models
curl -L -o ~/.local/share/whispertype/models/ggml-tiny.en.bin \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.en.bin

echo "=== 3. Setting Up Project Directories & Copilot Instructions ==="
mkdir -p src .github

cat << 'COPILOT' > .github/copilot-instructions.md
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
COPILOT

cat << 'CARGO' > Cargo.toml
[package]
name = "wispertype"
version = "0.1.0"
edition = "2021"

[dependencies]
anyhow = "1.0"
cpal = "0.15"
whisper-rs = "0.16"
tokio = { version = "1.35", features = ["full"] }
gtk4 = { version = "0.8", package = "gtk4" }
libadwaita = { version = "0.6", package = "libadwaita" }
shellexpand = "3.1"
CARGO

cat << 'AUDIO' > src/audio.rs
use anyhow::{anyhow, Result};
use cpal::traits::{DeviceTrait, HostTrait, StreamTrait};
use cpal::{SampleFormat, Stream};
use std::sync::{Arc, Mutex};

pub struct AudioRecorder {
    stream: Option<Stream>,
    buffer: Arc<Mutex<Vec<f32>>>,
}

impl AudioRecorder {
    pub fn new() -> Self {
        Self { stream: None, buffer: Arc::new(Mutex::new(Vec::new())) }
    }

    pub fn start_recording(&mut self) -> Result<()> {
        let host = cpal::default_host();
        let device = host.default_input_device().ok_or_else(|| anyhow!("No input device found"))?;
        let config = device.default_input_config()?;
        let buffer = Arc::clone(&self.buffer);
        buffer.lock().unwrap().clear();

        let stream = match config.sample_format() {
            SampleFormat::F32 => device.build_input_stream(
                &config.into(),
                move |data: &[f32], _| { buffer.lock().unwrap().extend_from_slice(data); },
                |_| {},
                None,
            )?,
            _ => return Err(anyhow!("Unsupported sample format")),
        };

        stream.play()?;
        self.stream = Some(stream);
        Ok(())
    }

    pub fn stop_recording(&mut self) -> Vec<f32> {
        self.stream = None;
        let mut guard = self.buffer.lock().unwrap();
        std::mem::take(&mut *guard)
    }
}
AUDIO

cat << 'STT' > src/stt.rs
use anyhow::{anyhow, Result};
use whisper_rs::{FullParams, SamplingStrategy, WhisperContext, WhisperContextParameters};

pub struct WhisperTranscriber {
    ctx: WhisperContext,
}

impl WhisperTranscriber {
    pub fn new(model_path: &str) -> Result<Self> {
        let ctx = WhisperContext::new_with_params(model_path, WhisperContextParameters::default())
            .map_err(|e| anyhow!("Failed to load model: {:?}", e))?;
        Ok(Self { ctx })
    }

    pub fn transcribe(&self, pcm_data: &[f32]) -> Result<String> {
        let mut state = self.ctx.create_state().map_err(|e| anyhow!("Failed state: {:?}", e))?;
        let mut params = FullParams::new(SamplingStrategy::Greedy { best_of: 1 });
        params.set_language(Some("en"));
        params.set_print_special(false);
        params.set_print_progress(false);

        state.full(params, pcm_data).map_err(|e| anyhow!("Transcribe failed: {:?}", e))?;
        let num = state.full_n_segments();
        
        let mut text = String::new();
        for i in 0..num {
            if let Some(segment) = state.get_segment(i) {
                if let Ok(segment_text) = segment.to_str() {
                    text.push_str(segment_text);
                }
            }
        }
        Ok(text)
    }
}
STT

cat << 'INJECTOR' > src/injector.rs
use anyhow::{anyhow, Result};
use std::process::Command;

pub fn type_text(text: &str) -> Result<()> {
    if text.trim().is_empty() { return Ok(()); }
    let status = Command::new("wtype").arg(text).status().map_err(|e| anyhow!("wtype error: {}", e))?;
    if !status.success() { return Err(anyhow!("wtype failed")); }
    Ok(())
}
INJECTOR

cat << 'MAIN' > src/main.rs
mod audio;
mod injector;
mod stt;

use anyhow::Result;
use audio::AudioRecorder;
use injector::type_text;
use stt::WhisperTranscriber;
use std::path::Path;
use std::io;

#[tokio::main]
async fn main() -> Result<()> {
    println!("=== WisperType Local Dictation Starting ===");
    let model_path = shellexpand::tilde("~/.local/share/whispertype/models/ggml-tiny.en.bin").to_string();
    
    if !Path::new(&model_path).exists() {
        eprintln!("Model missing at: {}", model_path);
        return Ok(());
    }

    let transcriber = WhisperTranscriber::new(&model_path)?;
    let mut recorder = AudioRecorder::new();

    println!("Press ENTER to START recording...");
    let mut line = String::new();
    io::stdin().read_line(&mut line)?;

    recorder.start_recording()?;
    println!("Recording... Press ENTER to STOP and transcribe.");

    line.clear();
    io::stdin().read_line(&mut line)?;

    let pcm_data = recorder.stop_recording();
    println!("Transcribing audio...");

    let text = transcriber.transcribe(&pcm_data)?;
    println!("Transcribed: '{}'", text.trim());

    type_text(text.trim())?;
    println!("Done!");
    Ok(())
}
MAIN

echo "=== 5. Creating Arch Linux PKGBUILD Package Recipe ==="
cat << 'PKGBUILD' > PKGBUILD
# Maintainer: Your Name <your.email@example.com>
pkgname=wispertype
pkgver=0.1.0
pkgrel=1
pkgdesc="Offline system-wide voice-to-text dictation tool for Wayland"
arch=('x86_64' 'aarch64')
url="https://github.com/yourusername/wispertype"
license=('MIT')
depends=('gtk4' 'libadwaita' 'pipewire' 'wtype')
makedepends=('cargo' 'git' 'clang' 'cmake')
source=("$pkgname-$pkgver.tar.gz::$url/archive/refs/tags/v$pkgver.tar.gz")
sha256sums=('SKIP')

build() {
  cd "$pkgname-$pkgver"
  cargo build --release --locked
}

package() {
  cd "$pkgname-$pkgver"
  install -Dm755 "target/release/$pkgname" "$pkgdir/usr/bin/$pkgname"
}
PKGBUILD

echo "=== 6. Initializing Git Repository ==="
git init
git add .
git commit -m "Initial commit of WisperType"

echo "=== 7. Verifying Rust Build ==="
cargo check

echo "=================================================="
echo "SETUP SUCCESSFUL!"
echo "Project created in WisperType/ directory."
echo "=================================================="
