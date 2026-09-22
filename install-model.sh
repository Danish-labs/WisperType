#!/usr/bin/env bash
set -e
mkdir -p "$HOME/.local/share/wispertype/models"
MODEL="$HOME/.local/share/wispertype/models/ggml-tiny.en.bin"
if [ ! -f "$MODEL" ]; then
  curl -L --fail -o "$MODEL" \
    "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.en.bin"
fi
