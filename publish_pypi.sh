#!/bin/bash
set -e

# Clean previous builds
rm -rf dist/ build/ *.egg-info/ src/*.egg-info/ python/*.egg-info/

# Install build dependencies
pip install build twine

# Build package
python -m build

# Check distribution
twine check dist/*

# Upload to PyPI
# Expects TWINE_USERNAME and TWINE_PASSWORD env vars, or interactive prompt
twine upload dist/*
