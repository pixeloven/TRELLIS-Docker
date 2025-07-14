#!/bin/bash

source ~/.venv/bin/activate

./post_install.sh

echo "Attempting to start TRELLIS on $GRADIO_SERVER_NAME:$GRADIO_SERVER_PORT"

# Launch TRELLIS application
python3 app.py
