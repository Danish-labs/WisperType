mod audio;
mod injector;
mod stt;

use anyhow::Result;
use audio::AudioRecorder;
use injector::type_text;
use stt::WhisperTranscriber;
use std::io;
use std::path::Path;

#[tokio::main]
async fn main() -> Result<()> {
    println!("=== WisperType Local Dictation Starting ===");
    let model_path = shellexpand::tilde(
        "~/.local/share/whispertype/models/ggml-tiny.en.bin",
    )
    .to_string();

    if !Path::new(&model_path).exists() {
        eprintln!("Model missing at: {model_path}");
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

    let pcm_data = recorder.stop_recording()?;
    println!("Transcribing audio...");

    let text = transcriber.transcribe(&pcm_data)?;
    println!("Transcribed: '{}'", text.trim());

    type_text(text.trim())?;
    println!("Done!");
    Ok(())
}
