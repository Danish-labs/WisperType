use anyhow::{anyhow, Result};
use std::process::Command;

pub fn type_text(text: &str) -> Result<()> {
    if text.trim().is_empty() { return Ok(()); }
    let status = Command::new("wtype").arg(text).status().map_err(|e| anyhow!("wtype error: {}", e))?;
    if !status.success() { return Err(anyhow!("wtype failed")); }
    Ok(())
}
