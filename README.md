# Trellis Docker Setup

This directory contains the Docker configuration for running Microsoft's TRELLIS (Text-to-3D Generation) service with optimized builds and multi-stage architecture.

## Quick Start

### Prerequisites
- Docker with Buildx support
- NVIDIA GPU with CUDA 12.4+ support
- NVIDIA Container Toolkit (nvidia-docker2)
- Git (for submodule management)

### Submodule Setup
This project uses the TRELLIS source code as a Git submodule for local development and contribution:

```bash
# Initialize and update the submodule (first time setup)
git submodule update --init --recursive

# Update the submodule to latest version
git submodule update --remote

# Switch to a specific branch or commit in the submodule
cd services/trellis/source
git checkout <branch-name>
cd ../../..
git add services/trellis/source
git commit -m "Update TRELLIS submodule to <branch-name>"
```

### Build and Run

```bash
# Build the Docker images using Docker Bake (recommended)
docker buildx bake all

# Or build specific targets
docker buildx bake trellis-nvidia

# Run the container
docker-compose up

# Or run in detached mode
docker-compose up -d
```

The service will be available at `http://localhost:7860` (Gradio interface).

## Architecture

### Multi-Stage Build System
This project uses Docker Bake for optimized multi-stage builds:

1. **Runtime Base** (`runtime-nvidia`): CUDA 12.4.1 + cuDNN development environment
2. **TRELLIS Application** (`trellis-nvidia`): Complete TRELLIS installation with all dependencies

### Base Image
- **CUDA**: 12.4.1 with cuDNN development
- **Ubuntu**: 22.04.4 LTS (Jammy Jellyfish)
- **Python**: 3.10.12 (via venv)
- **PyTorch**: 2.5.0+cu124 with CUDA 12.4 support

### Key Components
- **Virtual Environment**: Isolated Python environment in `/home/trellis/.venv`
- **User**: `trellis` (UID/GID: 1000) - non-root user for security
- **Working Directory**: `/home/trellis/app`
- **Port**: 7860 (Gradio web interface)
- **GPU Support**: NVIDIA GPU acceleration with proper CUDA setup

## Build Process

### 1. Runtime Base Setup
- Install system dependencies (ffmpeg, build tools, git, etc.)
- Set up CUDA 12.4.1 development environment
- Install latest pip and Python tools

### 2. TRELLIS Application Layer
- Create g++ wrapper for JIT compilation with CUDA includes
- Set up non-root user and virtual environment
- Clone Microsoft TRELLIS repository
- Install PyTorch ecosystem (pytorch 2.5.0, torchvision, torchaudio)

### 3. Package Installation
- **Core Dependencies**: Pillow, OpenCV, SciPy, Ninja, etc.
- **3D Libraries**: Trimesh, Open3D, PyVista, Kaolin
- **ML Libraries**: Transformers, xformers, flash-attn
- **GPU Libraries**: nvdiffrast, spconv-cu124
- **Web Interface**: Gradio 4.44.1 with litmodel3d

### 4. Optimization
- Use Docker layer caching for faster rebuilds
- Clean pip caches and temporary files
- Set proper permissions and executable scripts

## Docker Bake Configuration

### Available Targets
```bash
# Build all images
docker buildx bake all

# Build specific components
docker buildx bake runtime-nvidia    # CUDA runtime base
docker buildx bake trellis-nvidia    # Complete TRELLIS app

# Build groups
docker buildx bake runtime           # All runtime images
docker buildx bake trellis           # All TRELLIS images
```

### Build Arguments
- `REGISTRY_URL`: Container registry (default: `ghcr.io/pixeloven/trellis-docker/`)
- `IMAGE_LABEL`: Image tag (default: `latest`)
- `PLATFORMS`: Target platforms (default: `linux/amd64`)

## Runtime Configuration

### Environment Variables
- `GRADIO_SERVER_NAME`: "0.0.0.0" (bind to all interfaces)
- `GRADIO_SERVER_PORT`: "7860" (web interface port)
- `GRADIO_SHARE`: "False" (disable public sharing)
- `ATTENTION_BACKEND`: "flash-attn" (optimized attention)

### Volume Mounts
The container mounts several directories for persistence:
- `./data/trellis/models` → `/app/models` (model storage)
- `./data/trellis/outputs` → `/app/outputs` (generated 3D models)
- `./data/trellis/uploads` → `/app/uploads` (user uploads)
- `./data/trellis/configs` → `/app/configs` (configuration files)
- `./data/trellis/tmp` → `/app/tmp` (temporary files)
- `./data/trellis/cache` → `/home/trellis/.cache` (Python cache)

### GPU Configuration
- Uses NVIDIA Container Toolkit
- Reserved GPU device 0
- Compute and utility capabilities enabled

## Application Features

### Web Interface
- **Gradio Interface**: Modern web UI at port 7860
- **3D Model Viewer**: Integrated 3D model visualization
- **Text-to-3D Generation**: Direct text input for 3D model creation
- **Model Management**: Upload, download, and manage 3D models

### Performance Optimizations
- **Flash Attention**: Optimized transformer attention mechanisms
- **CUDA Acceleration**: Full GPU acceleration for 3D operations
- **Memory Management**: Efficient memory usage with proper cleanup
- **Caching**: Persistent model and cache storage

## Troubleshooting

### Common Issues

#### 1. Build Failures
**Problem**: Docker build fails during package installation
**Solution**: 
```bash
# Clean build cache and retry
docker buildx bake --no-cache all
```

#### 2. GPU Not Detected
**Problem**: Container can't access GPU
**Solution**: 
```bash
# Verify NVIDIA Container Toolkit
nvidia-docker run --rm nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi

# Check docker-compose GPU configuration
docker-compose config
```

#### 3. Port Already in Use
**Problem**: Port 7860 is already occupied
**Solution**: 
```bash
# Change port in docker-compose.yml or environment
GRADIO_SERVER_PORT=7861 docker-compose up
```

#### 4. Memory Issues
**Problem**: Container runs out of memory during 3D generation
**Solution**: 
```bash
# Increase Docker memory limit
# In Docker Desktop: Settings → Resources → Memory
# Or use docker run with --memory flag
```

### Logs and Debugging
```bash
# View container logs
docker-compose logs -f trellis

# Access container shell
docker-compose exec trellis bash

# Check GPU status inside container
docker-compose exec trellis nvidia-smi
```

## Development

### Local Development
```bash
# Build with development settings
docker buildx bake --set "*.args.DEV_MODE=true" all

# Run with volume mounts for code changes
docker-compose -f docker-compose.dev.yml up
```

### Working with the TRELLIS Submodule
The project uses a local copy of the TRELLIS source code for development and contribution:

```bash
# Make changes to TRELLIS source code
cd services/trellis/source
# Edit files, make improvements, etc.

# Test your changes by rebuilding the Docker image
cd ../../..
docker buildx bake trellis-nvidia

# Commit your changes to the submodule
cd services/trellis/source
git add .
git commit -m "Your improvements to TRELLIS"
git push origin <your-branch>

# Update the main project to point to your changes
cd ../../..
git add services/trellis/source
git commit -m "Update TRELLIS submodule with improvements"
```

#### Contributing Back to Microsoft TRELLIS
1. Fork the original Microsoft TRELLIS repository
2. Make your improvements in the `trellis-source` submodule
3. Test thoroughly with the Docker setup
4. Create a pull request to the original Microsoft repository
5. Once accepted, update the submodule to point to the official repository

### Adding New Packages
1. Add package to appropriate RUN command in `dockerfile.trellis.base`
2. Test compatibility with current PyTorch/CUDA versions
3. Update documentation if needed
4. Rebuild images: `docker buildx bake all`

### Custom Models
Place custom models in `./data/trellis/models/` directory. The container will automatically detect and load compatible models.

## File Structure

```
TRELLIS-Docker/
├── docker-bake.hcl              # Multi-stage build configuration
├── docker-compose.yml           # Production compose file
├── services/trellis/
│   ├── dockerfile.nvidia.runtime # CUDA runtime base
│   ├── dockerfile.trellis.base   # Main TRELLIS application
│   ├── app_wrapper.py           # Application launcher with fixes
│   ├── startup.sh               # Container startup script
│   ├── post_install.sh          # Post-installation setup
│   └── entrypoint.sh            # Container entrypoint
├── data/trellis/                # Persistent data directories
│   ├── models/                  # 3D models storage
│   ├── outputs/                 # Generated outputs
│   ├── uploads/                 # User uploads
│   ├── configs/                 # Configuration files
│   ├── tmp/                     # Temporary files
│   └── cache/                   # Python cache
└── README.md                    # This documentation
```

## Contributing

When contributing to this project:

1. **Test Build Process**: Ensure clean builds on different systems
2. **Update Documentation**: Document any new dependencies or requirements
3. **Follow Docker Best Practices**: Use multi-stage builds and layer caching
4. **Test GPU Compatibility**: Verify CUDA and PyTorch version compatibility

## Support

For issues with:
- **TRELLIS itself**: Check the [Microsoft TRELLIS repository](https://github.com/microsoft/TRELLIS)
- **Docker setup**: Review this documentation and troubleshooting section
- **GPU issues**: Verify NVIDIA drivers and Container Toolkit installation
- **Build problems**: Check Docker Buildx and Bake documentation

## License

This project is licensed under the same terms as the original TRELLIS project. See the [LICENSE](LICENSE) file for details. 