#!/bin/bash

source ~/.venv/bin/activate

# Run post install steps if they haven't been run yet
./post_install.sh

# export CXX=/usr/local/bin/gxx-wrapper

echo "Starting TRELLIS on $GRADIO_SERVER_NAME:$GRADIO_SERVER_PORT"
# Set Gradio environment variables to ensure proper binding
export GRADIO_SERVER_NAME=$GRADIO_SERVER_NAME
export GRADIO_SERVER_PORT=$GRADIO_SERVER_PORT
python3 launch_app.py

echo "Application exited unexpectedly."