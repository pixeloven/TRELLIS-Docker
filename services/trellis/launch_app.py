#!/usr/bin/env python3
"""
Wrapper script to launch TRELLIS with proper Gradio configuration.
This fixes the localhost binding issue by setting the correct server parameters.
"""

import os
import sys
import subprocess

def main():
    # Set environment variables for Gradio
    os.environ['GRADIO_SERVER_NAME'] = os.getenv('GRADIO_SERVER_NAME', '0.0.0.0')
    os.environ['GRADIO_SERVER_PORT'] = os.getenv('GRADIO_SERVER_PORT', '7860')
    
    print(f"Launching TRELLIS on {os.environ['GRADIO_SERVER_NAME']}:{os.environ['GRADIO_SERVER_PORT']}")
    
    # Launch the original app.py with proper Gradio configuration
    try:
        # Import and run the app with custom launch parameters
        import app
        
        # Find the demo object and relaunch it with proper configuration
        if hasattr(app, 'demo'):
            app.demo.launch(
                server_name=os.environ['GRADIO_SERVER_NAME'],
                server_port=int(os.environ['GRADIO_SERVER_PORT']),
                share=False,
                inbrowser=False
            )
        else:
            print("Error: Could not find demo object in app.py")
            sys.exit(1)
            
    except Exception as e:
        print(f"Error launching app: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main() 