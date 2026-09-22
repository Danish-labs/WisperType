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
        buffer.lock().map_err(|_| anyhow!("Audio buffer lock poisoned"))?.clear();

        let stream = match config.sample_format() {
            SampleFormat::F32 => device.build_input_stream(
                &config.into(),
                move |data: &[f32], _| {
                    if let Ok(mut buffer) = buffer.lock() {
                        buffer.extend_from_slice(data);
                    }
                },
                |_| {},
                None,
            )?,
            _ => return Err(anyhow!("Unsupported sample format")),
        };

        stream.play()?;
        self.stream = Some(stream);
        Ok(())
    }

    pub fn stop_recording(&mut self) -> Result<Vec<f32>> {
        self.stream = None;
        let mut buffer = self.buffer.lock().map_err(|_| anyhow!("Audio buffer lock poisoned"))?;
        Ok(std::mem::take(&mut *buffer))
    }
}
