#!/bin/bash

source ~/.venv/bin/activate

./post_install.sh

echo "Attempting to start TRELLIS on $GRADIO_SERVER_NAME:$GRADIO_SERVER_PORT"

# Set environment variables for Gradio
export GRADIO_SERVER_NAME=${GRADIO_SERVER_NAME:-"0.0.0.0"}
export GRADIO_SERVER_PORT=${GRADIO_SERVER_PORT:-"7860"}

# Ensure we're in the correct directory
cd /home/trellis/app

# Create a Python script to launch TRELLIS with proper configuration
cat > /tmp/launch_trellis.py << 'EOF'
#!/usr/bin/env python3
import os
import sys
import traceback

def patch_gradio_schema_bug():
    """Patch the Gradio JSON schema bug that causes TypeError: argument of type 'bool' is not iterable"""
    try:
        import gradio_client.utils as client_utils
        
        # Store the original function
        original_get_type = client_utils._json_schema_to_python_type
        
        def patched_get_type(schema, defs=None):
            """Patched version that handles boolean values in schema"""
            try:
                # Check if schema is a boolean (which causes the bug)
                if isinstance(schema, bool):
                    return "bool"
                
                # Check if schema has 'const' key and it's a boolean
                if isinstance(schema, dict) and "const" in schema:
                    const_value = schema["const"]
                    if isinstance(const_value, bool):
                        return "bool"
                
                # Call the original function
                return original_get_type(schema, defs)
            except TypeError as e:
                if "argument of type 'bool' is not iterable" in str(e):
                    # Handle the specific bug
                    if isinstance(schema, dict) and "additionalProperties" in schema:
                        additional_props = schema["additionalProperties"]
                        if isinstance(additional_props, bool):
                            return "dict"
                    return "any"
                raise
        
        # Replace the function
        client_utils._json_schema_to_python_type = patched_get_type
        print("Successfully patched Gradio JSON schema bug")
        
    except Exception as e:
        print(f"Warning: Could not patch Gradio schema bug: {e}")

def main():
    # Set environment variables
    os.environ['GRADIO_SERVER_NAME'] = os.environ.get('GRADIO_SERVER_NAME', '0.0.0.0')
    os.environ['GRADIO_SERVER_PORT'] = os.environ.get('GRADIO_SERVER_PORT', '7860')
    
    print(f"Starting TRELLIS with GRADIO_SERVER_NAME={os.environ['GRADIO_SERVER_NAME']}")
    print(f"Starting TRELLIS with GRADIO_SERVER_PORT={os.environ['GRADIO_SERVER_PORT']}")
    
    # Add current directory to Python path
    sys.path.insert(0, os.getcwd())
    
    # Patch the Gradio bug before importing the app
    patch_gradio_schema_bug()
    
    try:
        # Import the TRELLIS app
        import app
        print("TRELLIS app imported successfully")
        
        # Check if demo exists
        if hasattr(app, 'demo'):
            print("Launching TRELLIS Gradio interface...")
            
            # Launch with explicit configuration
            app.demo.launch(
                server_name=os.environ['GRADIO_SERVER_NAME'],
                server_port=int(os.environ['GRADIO_SERVER_PORT']),
                share=False,
                show_error=True,
                quiet=False
            )
        else:
            print("Warning: No 'demo' object found in app module")
            print("Available attributes in app module:", dir(app))
            
            # Try to find the demo object
            for attr_name in dir(app):
                attr = getattr(app, attr_name)
                if hasattr(attr, 'launch'):
                    print(f"Found launchable object: {attr_name}")
                    try:
                        attr.launch(
                            server_name=os.environ['GRADIO_SERVER_NAME'],
                            server_port=int(os.environ['GRADIO_SERVER_PORT']),
                            share=False,
                            show_error=True,
                            quiet=False
                        )
                        break
                    except Exception as e:
                        print(f"Failed to launch {attr_name}: {e}")
                        continue
            
    except ImportError as e:
        print(f"Error importing TRELLIS app: {e}")
        traceback.print_exc()
        sys.exit(1)
    except Exception as e:
        print(f"Error running TRELLIS app: {e}")
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
EOF

# Launch the Python script
echo "Attempting to launch TRELLIS with custom wrapper..."
if ! python3 /tmp/launch_trellis.py; then
    echo "Custom wrapper failed, trying direct launch..."
    
    # Fallback: Try to run the original app directly
    cat > /tmp/direct_launch.py << 'EOF'
#!/usr/bin/env python3
import os
import sys

# Set environment variables
os.environ['GRADIO_SERVER_NAME'] = os.environ.get('GRADIO_SERVER_NAME', '0.0.0.0')
os.environ['GRADIO_SERVER_PORT'] = os.environ.get('GRADIO_SERVER_PORT', '7860')

print("Attempting direct launch of TRELLIS...")

# Add current directory to Python path
sys.path.insert(0, os.getcwd())

try:
    # Try to import and run the app directly
    import app
    
    if hasattr(app, 'demo'):
        print("Launching demo directly...")
        app.demo.launch(
            server_name=os.environ['GRADIO_SERVER_NAME'],
            server_port=int(os.environ['GRADIO_SERVER_PORT']),
            share=False
        )
    else:
        print("No demo found, trying to run app as script...")
        # Try to run the app as a script
        exec(open('app.py').read())
        
except Exception as e:
    print(f"Direct launch failed: {e}")
    print("Trying to run app.py directly...")
    
    # Last resort: try to run app.py directly
    try:
        os.system(f"python3 app.py --server-name {os.environ['GRADIO_SERVER_NAME']} --server-port {os.environ['GRADIO_SERVER_PORT']}")
    except:
        print("All launch methods failed")
        sys.exit(1)
EOF

    python3 /tmp/direct_launch.py
fi
