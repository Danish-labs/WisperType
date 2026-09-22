mod audio;
mod injector;
mod stt;

use stt::WhisperTranscriber;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    println!("Starting WisperType...");

    // Instantiate WhisperTranscriber without passing path or using ?
    let transcriber = WhisperTranscriber::new();

    // Add your application loop or GUI initialization here
    println!("WisperType ready.");

    Ok(())
}
