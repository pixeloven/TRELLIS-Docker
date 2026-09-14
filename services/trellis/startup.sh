#!/bin/bash

source ~/.venv/bin/activate

./post_install.sh

echo "Attempting to start TRELLIS on ${GRADIO_SERVER_NAME:-0.0.0.0}:${GRADIO_SERVER_PORT:-7860}"

# Ensure we're in the correct directory
cd /home/trellis/app

# Launch TRELLIS using the wrapper (contains Gradio patch)
python3 app_wrapper.py
