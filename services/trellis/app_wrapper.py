#!/usr/bin/env python3
"""
Wrapper script for TRELLIS app that fixes the localhost binding issue.
This script monkey patches the demo.launch function to use GRADIO_SERVER_NAME environment variable.
"""

import os
import sys
import types

# This is a hack to fix the localhost binding issue.
# It should be removed when the issue is fixed in the original app.
# @todo Patch the app.py to use ENV
def patch_gradio_launch():
    """Monkey patch the demo.launch function to use environment variable"""
    
    # Store the original launch function
    original_launch = None
    
    def patched_launch(self, *args, **kwargs):
        """Patched launch function that uses GRADIO_SERVER_NAME environment variable"""
        # Get server name from environment, default to 0.0.0.0
        server_name = os.environ.get("GRADIO_SERVER_NAME", "0.0.0.0")
        
        # Set the server_name in kwargs if not already present
        if 'server_name' not in kwargs:
            kwargs['server_name'] = server_name
        
        print(f"Launching Gradio with server_name: {kwargs['server_name']}")
        
        # Call the original launch function
        if original_launch is not None:
            return original_launch(self, *args, **kwargs)
        else:
            print("Warning: Original launch function not found, using default")
            return self.launch(*args, **kwargs)
    
    # Import gradio and patch the Interface.launch method
    try:
        import gradio as gr
        
        # Store the original launch method
        original_launch = gr.Interface.launch
        
        # Replace the launch method with our patched version
        gr.Interface.launch = patched_launch
        
        print("Successfully patched gradio.Interface.launch")
        
    except ImportError as e:
        print(f"Warning: Could not import gradio: {e}")
    except Exception as e:
        print(f"Warning: Could not patch gradio launch: {e}")

def main():
    """Main function that patches gradio and runs the original app"""
    
    # Set default environment variables if not already set
    if "GRADIO_SERVER_NAME" not in os.environ:
        os.environ["GRADIO_SERVER_NAME"] = "0.0.0.0"
    
    if "GRADIO_SERVER_PORT" not in os.environ:
        os.environ["GRADIO_SERVER_PORT"] = "7860"
    
    print(f"Starting TRELLIS with GRADIO_SERVER_NAME={os.environ['GRADIO_SERVER_NAME']}")
    print(f"Starting TRELLIS with GRADIO_SERVER_PORT={os.environ['GRADIO_SERVER_PORT']}")
    
    # Patch the gradio launch function
    patch_gradio_launch()
    
    # Import and run the original app
    try:
        # Import the original app module
        import app
        
        print("TRELLIS app imported successfully")
        
        # Launch the app - the demo object should be available after importing app
        if hasattr(app, 'demo'):
            print("Launching TRELLIS Gradio interface...")
            app.demo.launch(
                server_name=os.environ.get("GRADIO_SERVER_NAME", "0.0.0.0"),
                server_port=int(os.environ.get("GRADIO_SERVER_PORT", "7860")),
                share=False
            )
        else:
            print("Warning: No 'demo' object found in app module")
            print("Available attributes in app module:", dir(app))
            
    except ImportError as e:
        print(f"Error importing TRELLIS app: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Error running TRELLIS app: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main() 