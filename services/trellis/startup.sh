#!/bin/bash

source ~/.venv/bin/activate

echo "Starting TRELLIS on $GRADIO_SERVER_NAME:$GRADIO_SERVER_PORT"
# Set Gradio environment variables to ensure proper binding
export GRADIO_SERVER_NAME=$GRADIO_SERVER_NAME
export GRADIO_SERVER_PORT=$GRADIO_SERVER_PORT

# Launch TRELLIS application
python3 app.py

echo "Application exited unexpectedly."