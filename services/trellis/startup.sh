#!/bin/bash

source ~/.venv/bin/activate

./post_install.sh

echo "Attempting to start TRELLIS on $GRADIO_SERVER_NAME:$GRADIO_SERVER_PORT"

# Check if we should use direct app execution or wrapper
if [ "${USE_DIRECT_APP:-false}" = "true" ]; then
    echo "🚀 Using direct app execution (no wrapper)"
    
    # Check which app to run
    if [ "${TRELLIS_MODE:-image}" = "text" ]; then
        echo "📝 Launching text-to-3D mode"
        python3 app_text.py
    else
        echo "🖼️  Launching image-to-3D mode"
        python3 app.py
    fi
else
    echo "🔧 Using app wrapper (with Gradio patch)"
    # Launch TRELLIS using the simple wrapper
    python3 app_wrapper.py
fi
