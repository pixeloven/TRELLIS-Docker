#!/bin/bash
set -e

# Check if post-install steps have already been run
echo "Running post-install setup..."
if [ -f .post_install_done ]; then
    echo "Post-install already completed, skipping."
    exit 0
fi

echo "Installing GPU-dependent packages..."
# Run the demo setup
./setup.sh --mipgaussian --diffoctreerast

echo "Fixing NumPy compatibility issues..."
# Reinstall Kaolin to ensure NumPy compatibility
pip uninstall -y kaolin
pip install kaolin==0.17.0 -f https://nvidia-kaolin.s3.us-east-2.amazonaws.com/torch-2.4.0_cu124.html

echo "Installing missing flash-attn..."
# Install flash-attn for attention mechanisms
pip install flash-attn --no-build-isolation

echo "Verifying installation..."

# export CXX=/usr/local/bin/gxx-wrapper
python test_imports.py

# Mark completion
touch .post_install_done

echo "Post-install completed successfully."