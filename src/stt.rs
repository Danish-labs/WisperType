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
        let num = state.full_n_segments().map_err(|e| anyhow!("Segment error: {:?}", e))?;
        
        let mut text = String::new();
        for i in 0..num {
            if let Ok(segment) = state.full_get_segment_text(i) {
                text.push_str(&segment);
            }
        }
        Ok(text)
    }
}
