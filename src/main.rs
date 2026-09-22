mod stt;

use stt::WhisperTranscriber;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    println!("Starting WisperType...");

    let _transcriber = WhisperTranscriber::new();

    println!("WisperType ready.");

    Ok(())
}
