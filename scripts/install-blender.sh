#!/bin/bash
# Install Blender 4.2 LTS static binary at /home/node/blender/.
# Required for the hero-renderer stage — provides the OpenImageDenoise denoiser
# that Debian's apt package was built without.
#
# Re-runnable: skips download if the binary is already installed and matches.

set -euo pipefail

VERSION="${BLENDER_VERSION:-4.2.9}"
SERIES="${VERSION%.*}"  # e.g. 4.2 from 4.2.9
INSTALL_DIR="${BLENDER_INSTALL_DIR:-/home/node/blender}"
TARBALL_URL="https://download.blender.org/release/Blender${SERIES}/blender-${VERSION}-linux-x64.tar.xz"

if [ -x "${INSTALL_DIR}/blender" ]; then
    INSTALLED=$("${INSTALL_DIR}/blender" --version 2>/dev/null | head -1 | awk '{print $2}')
    if [ "${INSTALLED}" = "${VERSION}" ]; then
        echo "[install-blender] Blender ${VERSION} already at ${INSTALL_DIR}"
        exit 0
    fi
    echo "[install-blender] Replacing ${INSTALLED} with ${VERSION}"
fi

echo "[install-blender] Downloading ${TARBALL_URL}"
mkdir -p "${INSTALL_DIR}"
cd "${INSTALL_DIR}"
curl -fsSL -o blender.tar.xz "${TARBALL_URL}"

echo "[install-blender] Extracting (this takes ~30s)"
tar -xf blender.tar.xz --strip-components=1
rm blender.tar.xz

# Verify OIDN is built in. Capture output first — Blender may exit nonzero on
# locale warnings, which would trip set -o pipefail and produce a false negative
# even when the OIDN_OK marker is present.
VERIFY_OUT=$("${INSTALL_DIR}/blender" --background --python-expr "
import bpy
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
try:
    scene.cycles.denoiser = 'OPENIMAGEDENOISE'
    print('OIDN_OK')
except Exception as e:
    print('OIDN_MISSING:', e)
" 2>&1 || true)

if echo "$VERIFY_OUT" | grep -q "OIDN_OK"; then
    echo "[install-blender] Blender ${VERSION} installed with OIDN denoiser"
else
    echo "[install-blender] WARNING: OIDN denoiser not detected in this build"
    echo "$VERIFY_OUT" | tail -10
    exit 1
fi
