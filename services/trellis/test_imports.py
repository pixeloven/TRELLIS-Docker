#!/usr/bin/env python3
"""
Simple test script to verify that all key modules can be imported.
This avoids the HuggingFace authentication issues.
"""

import sys
print(f"Python version: {sys.version}")

# Test basic imports
print("Testing basic imports...")
try:
    import torch
    print(f"✓ PyTorch: {torch.__version__}")
except ImportError as e:
    print(f"✗ PyTorch import failed: {e}")

try:
    import numpy as np
    print(f"✓ NumPy: {np.__version__}")
except ImportError as e:
    print(f"✗ NumPy import failed: {e}")

# Test Kaolin import
print("\nTesting Kaolin import...")
try:
    import kaolin
    print(f"✓ Kaolin: {kaolin.__version__}")
except ImportError as e:
    print(f"✗ Kaolin import failed: {e}")

# Test flash-attn import
print("\nTesting flash-attn import...")
try:
    import flash_attn
    print("✓ flash-attn imported successfully")
except ImportError as e:
    print(f"✗ flash-attn import failed: {e}")

# Test TRELLIS imports (without loading models)
print("\nTesting TRELLIS imports...")
try:
    from trellis import representations
    print("✓ TRELLIS representations imported")
except ImportError as e:
    print(f"✗ TRELLIS representations import failed: {e}")

try:
    from trellis import modules
    print("✓ TRELLIS modules imported")
except ImportError as e:
    print(f"✗ TRELLIS modules import failed: {e}")

print("\nAll import tests completed!") 