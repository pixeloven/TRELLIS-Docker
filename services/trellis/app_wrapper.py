#!/usr/bin/env python3
"""
Simple wrapper for TRELLIS app that fixes both localhost binding and Gradio JSON schema issues.
"""

import os
import sys
import traceback

def patch_gradio_issues():
    """Patch both the localhost binding and JSON schema issues"""
    
    # Patch 1: Fix JSON schema bug
    try:
        import gradio_client.utils as client_utils
        
        # Store original function
        original_get_type = client_utils._json_schema_to_python_type
        
        def patched_get_type(schema, defs=None):
            """Handle boolean values in schema that cause the TypeError"""
            try:
                if isinstance(schema, bool):
                    return "bool"
                if isinstance(schema, dict) and "const" in schema:
                    const_value = schema["const"]
                    if isinstance(const_value, bool):
                        return "bool"
                return original_get_type(schema, defs)
            except TypeError as e:
                if "argument of type 'bool' is not iterable" in str(e):
                    if isinstance(schema, dict) and "additionalProperties" in schema:
                        additional_props = schema["additionalProperties"]
                        if isinstance(additional_props, bool):
                            return "dict"
                    return "any"
                raise
        
        client_utils._json_schema_to_python_type = patched_get_type
        print("✅ Patched Gradio JSON schema bug")
        
    except Exception as e:
        print(f"⚠️  Could not patch Gradio schema bug: {e}")
    
    # Patch 2: Fix localhost binding by setting environment variables
    os.environ.setdefault('GRADIO_SERVER_NAME', '0.0.0.0')
    os.environ.setdefault('GRADIO_SERVER_PORT', '7860')
    print(f"✅ Set server binding to {os.environ['GRADIO_SERVER_NAME']}:{os.environ['GRADIO_SERVER_PORT']}")

def main():
    """Main function that patches issues and launches TRELLIS"""
    
    print("🚀 Starting TRELLIS with fixes applied...")
    
    # Apply patches
    patch_gradio_issues()
    
    # Add current directory to Python path
    sys.path.insert(0, os.getcwd())
    
    try:
        # Import and launch TRELLIS
        import app
        print("✅ TRELLIS app imported successfully")
        
        if hasattr(app, 'demo'):
            print("🎯 Launching TRELLIS Gradio interface...")
            app.demo.launch(
                server_name=os.environ['GRADIO_SERVER_NAME'],
                server_port=int(os.environ['GRADIO_SERVER_PORT']),
                share=False
            )
        else:
            print("❌ No 'demo' object found in app module")
            sys.exit(1)
            
    except Exception as e:
        print(f"❌ Error launching TRELLIS: {e}")
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main() 