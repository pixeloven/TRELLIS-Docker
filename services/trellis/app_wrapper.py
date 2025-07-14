#!/usr/bin/env python3
"""
Simple wrapper for TRELLIS app that fixes Gradio JSON schema issues.
"""

import os
import sys
import traceback

def patch_gradio_issues():
    """Patch the Gradio JSON schema bug"""
    
    # Patch: Fix JSON schema bug
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

def main():
    """Main function that patches issues and launches TRELLIS"""
    
    print("🚀 Starting TRELLIS with Gradio patch applied...")
    
    # Apply patches
    patch_gradio_issues()
    
    # Add source directory to Python path
    source_dir = os.path.join(os.path.dirname(__file__), 'source')
    sys.path.insert(0, source_dir)
    
    try:
        # Change to source directory and import app
        os.chdir(source_dir)
        import app
        print("✅ TRELLIS app imported successfully")
        
        # The app will handle environment variables and launch automatically
        print("🎯 TRELLIS will launch with environment variables...")
        
    except Exception as e:
        print(f"❌ Error launching TRELLIS: {e}")
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main() 