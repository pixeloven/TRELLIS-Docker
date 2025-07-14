#!/bin/bash
set -e

# Check if post-install steps have already been run
echo "Doing post install steps"
if [ -f .post_install_done ]; then
    echo "Post-install steps already completed."
    exit 0
fi

# Install TRELLIS extensions (mipgaussian, diffoctreerast)
source ~/.venv/bin/activate && \
mkdir -p /tmp/extensions && \
git clone --recurse-submodules https://github.com/JeffreyXiang/diffoctreerast.git /tmp/extensions/diffoctreerast && \
pip install /tmp/extensions/diffoctreerast && \
git clone https://github.com/autonomousvision/mip-splatting.git /tmp/extensions/mip-splatting && \
pip install /tmp/extensions/mip-splatting/submodules/diff-gaussian-rasterization/

# Mark completion
touch .post_install_done

echo "Post-install steps completed successfully."