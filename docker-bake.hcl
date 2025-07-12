// Docker Bake configuration for TRELLIS-Docker
// Supports multiple runtimes with proper caching and GitHub Container Registry

// Variables with defaults
variable "REGISTRY_URL" {
    default = "ghcr.io/pixeloven/trellis-docker/"
}

variable "IMAGE_LABEL" {
    default = "latest"
}

variable "RUNTIME" {
    default = "nvidia"
}

variable "PLATFORMS" {
    default = ["linux/amd64"]
}

target "runtime-nvidia" {
    context = "services/trellis"
    dockerfile = "dockerfile.nvidia.runtime"
    platforms = PLATFORMS
    tags = [
        "${REGISTRY_URL}runtime-nvidia:${IMAGE_LABEL}"
    ]
    cache-from = ["type=registry,ref=${REGISTRY_URL}runtime-nvidia:cache"]
    cache-to   = ["type=inline"]
}

target "trellis-nvidia" {
    context = "services/trellis"
    contexts = {
        runtime = "target:runtime-nvidia"
    }
    dockerfile = "dockerfile.trellis.base"
    platforms = PLATFORMS
    tags = [
        "${REGISTRY_URL}trellis-nvidia:${IMAGE_LABEL}"
    ]
    cache-from = [
        "type=registry,ref=${REGISTRY_URL}runtime-nvidia:cache",
        "type=registry,ref=${REGISTRY_URL}trellis-nvidia:cache"
    ]
    cache-to   = ["type=inline"]
    args = {
        RUNTIME = "nvidia"
    }
    depends_on = ["runtime-nvidia"]
}

// Convenience groups
group "default" {
    targets = ["all"]
}

group "all" {
    targets = ["runtime", "trellis"]
}

// Base runtime images
group "runtime" {
    targets = ["runtime-nvidia"]
}

group "nvidia" {
    targets = ["runtime-nvidia"]
}

group "trellis" {
    targets = ["trellis-nvidia"]
}

