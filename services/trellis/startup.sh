#!/bin/bash

source ~/.venv/bin/activate

./post_install.sh

echo "Attempting to start TRELLIS on $GRADIO_SERVER_NAME:$GRADIO_SERVER_PORT"

# Set environment variables for Gradio
export GRADIO_SERVER_NAME=${GRADIO_SERVER_NAME:-"0.0.0.0"}
export GRADIO_SERVER_PORT=${GRADIO_SERVER_PORT:-"7860"}

# Ensure we're in the correct directory
cd /home/trellis/app

# Launch TRELLIS using the simple wrapper
python3 app_wrapper.py
