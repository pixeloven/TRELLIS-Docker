# Trellis Docker Setup

This directory contains the Docker configuration for running Microsoft's TRELLIS (Text-to-3D Generation) service.

## Overview

TRELLIS is a text-to-3D generation pipeline that can create 3D models from text descriptions. This Docker setup provides a containerized environment with all necessary dependencies.

## Quick Start

```bash
# Build the Docker image
docker-compose build

# Run the container
docker-compose up
```

The service will be available at `http://localhost:7860` (Gradio interface).

## Architecture

### Base Image
- **PyTorch**: `pytorch/pytorch:2.4.0-cuda12.4-cudnn9-devel`
- **CUDA**: 12.4
- **Python**: 3.12

### Key Components
- **Conda Environment**: `trellis` - isolated Python environment
- **User**: `trellis` (UID/GID: 1000) - non-root user for security
- **Working Directory**: `/home/trellis/app`
- **Port**: 7860 (Gradio web interface)

## Build Process

### 1. Base Setup
- Install system dependencies (ffmpeg, build tools, git, etc.)
- Create g++ wrapper for JIT compilation
- Set up non-root user

### 2. Conda Environment
- Initialize conda with proper channels
- Create `trellis` environment
- Install PyTorch ecosystem (pytorch, torchvision, torchaudio, pytorch-cuda)

### 3. TRELLIS Installation
- Clone Microsoft TRELLIS repository
- Run setup script with basic components
- Install additional Python packages

### 4. Optimization
- Clean conda and pip caches
- Deduplicate files with rdfind
- Set proper permissions

## Troubleshooting

### Common Build Issues

#### 1. Conda Activation Errors
**Problem**: `CondaError: Run 'conda init' before 'conda activate'`
**Solution**: Use `conda run -n trellis` instead of `conda activate` in RUN commands

#### 2. PyTorch/Torchvision Version Mismatch
**Problem**: `RuntimeError: operator torchvision::nms does not exist`
**Solution**: Use compatible versions or let conda resolve dependencies automatically

#### 3. Missing Torch During Pip Install
**Problem**: `ModuleNotFoundError: No module named 'torch'`
**Solution**: Install PyTorch packages before pip packages that depend on them

#### 4. Package Build Failures
**Problem**: Packages like `flash_attn`, `spconv`, `diso` fail to build
**Solution**: These packages require specific CUDA/PyTorch versions or pre-built wheels

### Current Limitations

The following packages are currently excluded due to compatibility issues:
- `flash_attn` - Requires specific CUDA/PyTorch versions
- `spconv` - Needs pre-built wheels for current environment
- `diso` - Build-time torch dependency issues

## Advanced Package Installation

### Flash Attention
Flash Attention provides optimized attention mechanisms for transformers.

**Manual Installation (if needed):**
```bash
# Check compatibility first
conda run -n trellis pip install flash-attn --no-build-isolation

# Or install from source with specific CUDA version
conda run -n trellis pip install flash-attn --no-build-isolation --no-cache-dir
```

**Requirements:**
- CUDA 11.6+ or 12.1+
- PyTorch 2.0+
- Compatible Python version

### Sparse Convolution (spconv)
Sparse convolution operations for 3D point clouds.

**Installation Options:**
```bash
# Try pre-built wheel
conda run -n trellis pip install spconv-cu121  # for CUDA 12.1
conda run -n trellis pip install spconv-cu118  # for CUDA 11.8

# Or build from source
conda run -n trellis pip install spconv --no-cache-dir
```

**Requirements:**
- CUDA 11.8+ or 12.1+
- PyTorch 2.0+
- C++ build tools

### DISO (3D Gaussian Splatting)
3D Gaussian splatting for point cloud rendering.

**Installation:**
```bash
# Install after torch is available
conda run -n trellis pip install diso

# May require additional dependencies
conda run -n trellis pip install ninja
```

## Runtime Configuration

### Environment Variables
- `GRADIO_SERVER_NAME`: "0.0.0.0" (bind to all interfaces)
- `GRADIO_SERVER_PORT`: "7860" (web interface port)
- `CXX`: Custom g++ wrapper for JIT compilation

### Post-Install Process
The container runs post-install steps on first startup:
1. GPU-dependent package installation
2. Model verification
3. Application launch

### File Permissions
- Scripts are made executable during build
- All files owned by `trellis` user
- Proper permissions for security

## Development Recommendations

### 1. Package Management
- **Use conda for PyTorch ecosystem**: More reliable than pip for CUDA packages
- **Install pip packages after conda**: Ensures torch is available
- **Test package compatibility**: Check PyTorch/CUDA version requirements

### 2. Build Optimization
- **Layer caching**: Order RUN commands to maximize cache usage
- **Multi-stage builds**: Consider separating build and runtime stages
- **Package cleanup**: Always clean conda/pip caches

### 3. Runtime Considerations
- **GPU requirements**: Ensure NVIDIA drivers and nvidia-docker are installed
- **Memory usage**: Monitor container memory usage during 3D generation
- **Model caching**: Consider volume mounts for persistent model storage

### 4. Troubleshooting Workflow
1. **Check base image compatibility**: Verify PyTorch/CUDA versions
2. **Test package installation**: Install packages individually to isolate issues
3. **Use compatible versions**: Let package managers resolve dependencies
4. **Monitor build logs**: Look for specific error messages and version conflicts

## File Structure

```
services/trellis/
├── Dockerfile              # Main container definition
├── docker-compose.yml      # Development compose file
├── docker-swarm.yml        # Production swarm file
├── onstart.sh             # Container startup script
├── post_install.sh        # Post-installation setup
├── env.example            # Environment variables template
├── README.md              # This documentation
└── .dockerignore          # Docker build exclusions
```

## Contributing

When adding new packages or modifying the build:

1. **Test compatibility**: Verify package works with current PyTorch/CUDA versions
2. **Update documentation**: Document any new dependencies or requirements
3. **Test build process**: Ensure clean builds on different systems
4. **Consider alternatives**: Look for pre-built wheels or alternative packages

## Support

For issues with:
- **TRELLIS itself**: Check the [Microsoft TRELLIS repository](https://github.com/microsoft/TRELLIS)
- **Docker setup**: Review this documentation and troubleshooting section
- **Package compatibility**: Check individual package documentation for version requirements 