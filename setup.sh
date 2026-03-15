#!/usr/bin/env bash
set -euo pipefail

# Install system dependencies for 3D printing pipeline
# Run with: sudo bash setup.sh

echo "Installing OpenSCAD, Xvfb, and PrusaSlicer..."
apt-get update
apt-get install -y --no-install-recommends openscad xvfb prusa-slicer
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "Verifying OpenSCAD..."
xvfb-run openscad --version

echo "Verifying PrusaSlicer..."
prusa-slicer --version 2>/dev/null || echo "PrusaSlicer CLI not available (non-fatal)"

echo "Setting up Python virtual environment..."
cd "$(dirname "$0")"
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt

echo "Verifying Python deps..."
.venv/bin/python3 -c "import trimesh; import pyvista; print('Python deps OK')"

echo "Done. System dependencies installed."
