use anyhow::{anyhow, Result};
use reqwest::multipart;

#[allow(dead_code)]
pub struct WhisperTranscriber {
    client: reqwest::Client,
    server_url: String,
}

impl WhisperTranscriber {
    pub fn new() -> Self {
        Self {
            client: reqwest::Client::new(),
            server_url: "http://127.0.0.1:8080/inference".to_string(),
        }
    }

    #[allow(dead_code)]
    pub async fn transcribe(&self, pcm_data: &[f32]) -> Result<String> {
        let wav_data = create_wav_buffer(pcm_data, 16000)?;
        let part = multipart::Part::bytes(wav_data)
            .file_name("audio.wav")
            .mime_str("audio/wav")?;

        let form = multipart::Form::new().part("file", part);

        let res = self.client.post(&self.server_url)
            .multipart(form)
            .send()
            .await
            .map_err(|e| anyhow!("Failed to reach whisper server: {}", e))?;

        let text = res.text().await.map_err(|e| anyhow!("Failed to read response: {}", e))?;
        Ok(text)
    }
}

#[allow(dead_code)]
fn create_wav_buffer(samples: &[f32], sample_rate: u32) -> Result<Vec<u8>> {
    let mut cursor = std::io::Cursor::new(Vec::new());
    let spec = hound::WavSpec {
        channels: 1,
        sample_rate,
        bits_per_sample: 16,
        sample_format: hound::SampleFormat::Int,
    };
    
    let mut writer = hound::WavWriter::new(&mut cursor, spec)?;
    for &sample in samples {
        let sample_i16 = (sample.clamp(-1.0, 1.0) * 32767.0) as i16;
        writer.write_sample(sample_i16)?;
    }
    writer.finalize()?;
    Ok(cursor.into_inner())
}
