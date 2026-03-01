#!/usr/bin/env bash
set -euo pipefail

# Install system dependencies for 3D printing pipeline
# Run with: sudo bash setup.sh

echo "Installing OpenSCAD and Xvfb..."
apt-get update
apt-get install -y --no-install-recommends openscad xvfb
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "Verifying installation..."
xvfb-run openscad --version

echo "Setting up Python virtual environment..."
cd "$(dirname "$0")"
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt

echo "Verifying Python deps..."
.venv/bin/python3 -c "import trimesh; import pyvista; print('Python deps OK')"

echo "Done. System dependencies installed."
