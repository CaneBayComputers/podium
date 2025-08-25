#!/bin/bash
set -e

# Build Podium CLI .deb package

echo "🚀 Building Podium CLI .deb package..."

# Get version from control file or use default
VERSION=$(grep "Version:" debian-package/DEBIAN/control | cut -d' ' -f2)
PACKAGE_NAME="podium-cli_${VERSION}_all"

# Clean up any existing build
rm -rf "${PACKAGE_NAME}"
rm -f "${PACKAGE_NAME}.deb"

# Create fresh package structure
echo "Creating package structure..."
mkdir -p "${PACKAGE_NAME}/DEBIAN"
mkdir -p "${PACKAGE_NAME}/usr/local/share/podium-cli"
mkdir -p "${PACKAGE_NAME}/usr/local/bin"

# Copy DEBIAN control files
echo "Copying DEBIAN control files..."
cp debian-package/DEBIAN/* "${PACKAGE_NAME}/DEBIAN/"

# Copy application files
echo "Copying Podium CLI files..."
cp -r ../src/* "${PACKAGE_NAME}/usr/local/share/podium-cli/"
cp ../README.md "${PACKAGE_NAME}/usr/local/share/podium-cli/"
cp ../LICENSE "${PACKAGE_NAME}/usr/local/share/podium-cli/"

# Note: Projects directory is now user-configurable, not part of installation

# Set proper permissions
echo "Setting permissions..."
chmod -R 755 "${PACKAGE_NAME}/usr/local/share/podium-cli"
chmod +x "${PACKAGE_NAME}/usr/local/share/podium-cli/podium"
chmod +x "${PACKAGE_NAME}/usr/local/share/podium-cli/scripts"/*.sh
chmod +x "${PACKAGE_NAME}/DEBIAN/postinst"
chmod +x "${PACKAGE_NAME}/DEBIAN/prerm"

# Build the package
echo "Building .deb package..."
dpkg-deb --build "${PACKAGE_NAME}"

# Clean up build directory
rm -rf "${PACKAGE_NAME}"

echo ""
echo "✅ Package built successfully: ${PACKAGE_NAME}.deb"
echo ""
echo "To test the package:"
echo "  sudo dpkg -i ${PACKAGE_NAME}.deb"
echo ""
echo "To remove the package:"
echo "  sudo apt remove podium-cli"
echo ""
echo "Package info:"
dpkg-deb --info "${PACKAGE_NAME}.deb"
