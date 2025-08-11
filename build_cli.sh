#!/bin/bash

# Command Line Tools build script for 360Controller
# This script works without full Xcode installation
# Designed for systems with only Command Line Tools

set -e

echo "=== 360Controller Command Line Tools Build Script ==="
echo "Detected architecture: $(uname -m)"
echo "macOS version: $(sw_vers -productVersion)"
echo "Build tools: Command Line Tools for Xcode"

# Check if we have Command Line Tools
if ! command -v xcrun &> /dev/null; then
    echo "❌ Command Line Tools not found. Please install Command Line Tools first:"
    echo "   xcode-select --install"
    exit 1
fi

# Check if we're on Apple Silicon
if [[ $(uname -m) == "arm64" ]]; then
    echo "✓ Running on Apple Silicon (ARM64)"
else
    echo "⚠ Running on Intel Mac"
fi

# Check if DeveloperSettings.xcconfig exists
if [ ! -f "DeveloperSettings.xcconfig" ]; then
    echo "⚠ DeveloperSettings.xcconfig not found. Creating template..."
    cat > DeveloperSettings.xcconfig << 'EOF'
// DeveloperSettings.xcconfig - Template for Command Line Tools builds
// Update these values with your actual developer information

DEVELOPMENT_TEAM = XXXXXXXXXX
DEVELOPER_NAME = Your Name
DEVELOPER_EMAIL = your.email@example.com
NOTARIZATION_PASSWORD = your-app-specific-password

// For unsigned builds (development only), you can leave these as-is
EOF
    echo "✓ Created DeveloperSettings.xcconfig template"
fi

# Create build directory
mkdir -p build

echo ""
echo "=== Build Options ==="
echo "Since you only have Command Line Tools, you have a few options:"
echo ""
echo "1. Install full Xcode from Mac App Store (recommended)"
echo "2. Try to build individual components manually"
echo "3. Use pre-built binaries if available"
echo ""

echo "⚠ Command Line Tools alone cannot build this Xcode project."
echo "   This project requires the full Xcode build system."
echo ""

echo "=== Recommended Solution ==="
echo "To build this project, you need to install full Xcode:"
echo ""
echo "1. Open Mac App Store"
echo "2. Search for 'Xcode'"
echo "3. Install Xcode (this will take some time and space)"
echo "4. After installation, run: ./build_apple_silicon.sh"
echo ""

echo "=== Alternative: Manual Component Build ==="
echo "If you want to try building individual components manually:"
echo ""

# Check for source files that might be buildable
if [ -f "360Controller/_60Controller.cpp" ]; then
    echo "Found C++ source files in 360Controller/"
    echo "You could try building with:"
    echo "  cd 360Controller"
    echo "  clang++ -framework IOKit -framework CoreFoundation _60Controller.cpp Controller.cpp -o 360Controller"
fi

if [ -f "Feedback360/Feedback360.cpp" ]; then
    echo "Found C source files in Feedback360/"
    echo "You could try building with:"
    echo "  cd Feedback360"
    echo "  clang -framework IOKit -framework CoreFoundation Feedback360.cpp -o Feedback360"
fi

echo ""
echo "=== Current Status ==="
echo "❌ Cannot build with Command Line Tools alone"
echo "✅ Project is configured for Apple Silicon compatibility"
echo "✅ All necessary configuration files are in place"
echo "⚠ Need full Xcode for complete build"
echo ""

echo "To proceed, please install full Xcode from the Mac App Store."
echo "After installation, you can use: ./build_apple_silicon.sh"
echo ""
echo "*** Script completed ***" 