#!/bin/bash
set -eo pipefail

# Read version from pyproject.toml
VERSION=$(grep "^version" pyproject.toml | sed 's/version = "\(.*\)"/\1/')
if [[ -z "$VERSION" ]]; then
    echo "Error: Could not extract version from pyproject.toml"
    exit 1
fi

# Configuration
IMAGE_NAME="cagojeiger/openhands:${VERSION}-vscode-fix"
PLATFORMS="linux/amd64,linux/arm64"

echo "Building OpenHands Docker image"
echo "Version: ${VERSION}"
echo "Image: ${IMAGE_NAME}"
echo "Platforms: ${PLATFORMS}"

# Setup buildx if needed
if ! docker buildx inspect openhands-builder >/dev/null 2>&1; then
    docker buildx create --name openhands-builder --use
fi

# Build and push
docker buildx build \
    --platform "${PLATFORMS}" \
    --build-arg OPENHANDS_BUILD_VERSION="${VERSION}" \
    -f containers/app/Dockerfile \
    -t "${IMAGE_NAME}" \
    --push \
    .

echo "Done! Image pushed to: ${IMAGE_NAME}"