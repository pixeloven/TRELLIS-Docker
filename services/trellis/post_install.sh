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

echo "Verifying installation..."

# Mark completion
touch .post_install_done

echo "Post-install completed successfully."