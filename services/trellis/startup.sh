#!/bin/bash

source ~/.venv/bin/activate

echo "Attempting to start TRELLIS on $GRADIO_SERVER_NAME:$GRADIO_SERVER_PORT"

# Launch TRELLIS application
python3 app.py
