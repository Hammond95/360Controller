#!/bin/bash

# Apple Silicon optimized build script for 360Controller
# This script is specifically designed for M1/M2 Macs running macOS Sequoia
# Works with both full Xcode and Command Line Tools

set -e

# Build only non-wireless targets by default
TARGET_FLAGS="-target 360Controller -target Pref360Control -target Feedback360 -target 360Daemon"
SKIP_INSTALLER=${SKIP_INSTALLER:-1}

echo "=== 360Controller Apple Silicon Build Script ==="
echo "Detected architecture: $(uname -m)"
echo "macOS version: $(sw_vers -productVersion)"

# Check if we have Xcode or Command Line Tools
if command -v xcodebuild &> /dev/null; then
    echo "Xcode version: $(xcodebuild -version | head -1)"
    BUILD_TOOL="xcodebuild"
elif command -v xcrun &> /dev/null; then
    echo "Using Command Line Tools for Xcode"
    BUILD_TOOL="xcrun"
else
    echo "❌ Neither Xcode nor Command Line Tools found. Please install Xcode or Command Line Tools first."
    exit 1
fi

# Check if we're on Apple Silicon
if [[ $(uname -m) == "arm64" ]]; then
    echo "✓ Running on Apple Silicon (ARM64)"
    ARCH_FLAGS=""
else
    echo "⚠ Running on Intel Mac, but building for Apple Silicon compatibility"
    ARCH_FLAGS=""
fi

# Check if DeveloperSettings.xcconfig exists
if [ ! -f "DeveloperSettings.xcconfig" ]; then
    echo "⚠ DeveloperSettings.xcconfig not found. Creating template..."
    cat > DeveloperSettings.xcconfig << 'EOF'
// DeveloperSettings.xcconfig - Template for Apple Silicon builds
// Update these values with your actual developer information

DEVELOPMENT_TEAM = XXXXXXXXXX
DEVELOPER_NAME = Martin De Luca
DEVELOPER_EMAIL = martindeluca95@gmail.com
NOTARIZATION_PASSWORD = your-app-specific-password

// For unsigned builds (development only), you can leave these as-is
EOF
    echo "✓ Created DeveloperSettings.xcconfig template"
    echo "⚠ Please update DeveloperSettings.xcconfig with your developer information"
fi

# Check if we have valid developer certificates
echo "Checking for developer certificates..."
if security find-identity -v -p codesigning | grep -q "Developer ID Application"; then
    echo "✓ Developer ID Application certificate found"
    CODE_SIGNING="enabled"
    CODE_SIGN_IDENTITY="Developer ID Application"
else
    echo "⚠ No Developer ID Application certificate found"
    echo "⚠ Building without code signing (development mode)"
    CODE_SIGNING="disabled"
    CODE_SIGN_IDENTITY=""
fi

# Create build directory
mkdir -p build

# Build the project
echo "Building 360Controller for Apple Silicon (excluding wireless targets)..."

if [ "$BUILD_TOOL" = "xcodebuild" ]; then
    # Full Xcode available
    if [ "$CODE_SIGNING" = "enabled" ]; then
        echo "Building with code signing..."
        xcrun xcodebuild \
            -configuration Release \
            $TARGET_FLAGS \
            -xcconfig "DeveloperSettings.xcconfig" \
            -arch arm64 \
            -arch x86_64 \
            OTHER_CODE_SIGN_FLAGS="--timestamp --options=runtime" \
            CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" \
            CODE_SIGN_STYLE="Manual"
    else
        echo "Building without code signing (development mode)..."
        xcrun xcodebuild \
            -configuration Release \
            $TARGET_FLAGS \
            -xcconfig "DeveloperSettings.xcconfig" \
            -arch arm64 \
            -arch x86_64 \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGN_STYLE="Manual" \
            CODE_SIGNING_REQUIRED=NO \
            CODE_SIGNING_ALLOWED=NO
    fi
else
    # Command Line Tools only - try alternative build method
    echo "⚠ Full Xcode not available. Attempting build with Command Line Tools..."
    
    # Check if we can build with make or other tools
    if [ -f "Makefile" ]; then
        echo "Found Makefile, attempting make build..."
        make clean
        make
    elif [ -f "CMakeLists.txt" ]; then
        echo "Found CMakeLists.txt, attempting cmake build..."
        mkdir -p build_cmake
        cd build_cmake
        cmake ..
        make
        cd ..
    else
        echo "❌ No suitable build system found. Please install full Xcode for building this project."
        echo "   Command Line Tools alone are not sufficient for this Xcode project."
        exit 1
    fi
fi

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✓ Build completed successfully!"

echo ""
echo "=== Architecture Information ==="

if [ -f "build/Release/360Controller.kext/Contents/MacOS/360Controller" ]; then
    echo "360Controller.kext:"
    xcrun lipo -info build/Release/360Controller.kext/Contents/MacOS/360Controller
fi

if [ -f "build/Release/360Controller.kext/Contents/PlugIns/Feedback360.plugin/Contents/MacOS/Feedback360" ]; then
    echo "Feedback360.plugin:"
    xcrun lipo -info build/Release/360Controller.kext/Contents/PlugIns/Feedback360.plugin/Contents/MacOS/Feedback360
fi

if [ -f "build/Release/360Daemon.app/Contents/MacOS/360Daemon" ]; then
    echo "360Daemon.app:"
    xcrun lipo -info build/Release/360Daemon.app/Contents/MacOS/360Daemon
fi

if [ -f "build/Release/Pref360Control.prefPane/Contents/MacOS/Pref360Control" ]; then
    echo "Pref360Control.prefPane:"
    xcrun lipo -info build/Release/Pref360Control.prefPane/Contents/MacOS/Pref360Control
fi

if [ -f "build/Release/Pref360Control.prefPane/Contents/Resources/DriverTool" ]; then
    echo "DriverTool:"
    xcrun lipo -info build/Release/Pref360Control.prefPane/Contents/Resources/DriverTool
fi

# Build installer package (optional)
if [ "$SKIP_INSTALLER" = "1" ]; then
    echo "\n=== Skipping Installer Package (developer mode) ==="
else
    echo "\n=== Building Installer Package ==="
    cd Install360Controller

    if command -v packagesbuild &> /dev/null; then
        echo "Packages.app detected. Preparing to build .pkg..."
        # Detect Developer ID Installer identity if available
        PKG_IDENTITY=$(security find-identity -v -p codesigning 2>/dev/null | awk -F '"' '/Developer ID Installer/{print $2; exit}')
        if [ -n "$PKG_IDENTITY" ]; then
            echo "Signing installer with identity: $PKG_IDENTITY"
            packagesbuild -v Install360Controller.pkgproj --identity "$PKG_IDENTITY"
        else
            echo "⚠ No 'Developer ID Installer' certificate found. Building unsigned package..."
            packagesbuild -v Install360Controller.pkgproj
        fi
        # Wrap into DMG
        rm -rf ../build/360ControllerInstall 2>/dev/null || true
        mv build ../build/360ControllerInstall
        hdiutil create -srcfolder ../build/360ControllerInstall -fs HFS+ -format UDZO ../build/360ControllerInstall.dmg
        mv ../build/360ControllerInstall build
        echo "✓ Installer artifact: ../build/360ControllerInstall.dmg"
    else
        echo "⚠ Packages.app not found. Skipping installer package creation."
        echo "  You can install the driver manually by copying the .kext files."
    fi

    cd ..
fi

echo ""
echo "=== Build Summary ==="
if [ "$BUILD_TOOL" = "xcodebuild" ]; then
    echo "✓ 360Controller built for Apple Silicon (ARM64) and Intel (x86_64)"
    echo "✓ All binaries are universal (support both architectures)"
    if [ "$CODE_SIGNING" = "enabled" ]; then
        echo "✓ Build signed with Developer ID Application certificate"
    else
        echo "⚠ Build completed without code signing (development mode)"
        echo "⚠ You may need to disable SIP to load unsigned kexts"
    fi
else
    echo "⚠ Build completed with Command Line Tools (limited functionality)"
    echo "⚠ For full functionality, install full Xcode from Mac App Store"
fi
echo "✓ Build artifacts are in the 'build/Release' directory"

echo ""
echo "To install the driver:"
echo "1. Copy 360Controller.kext to /Library/Extensions/"
echo "2. Copy Pref360Control.prefPane to ~/Library/PreferencePanes/"
echo "3. Copy 360Daemon.app to /Applications/"
echo "4. Run: sudo kextload /Library/Extensions/360Controller.kext"

echo ""
if [ "$CODE_SIGNING" = "disabled" ]; then
    echo "⚠ IMPORTANT: This build is unsigned. You MUST disable System Integrity Protection (SIP) to load it."
    echo "⚠ To disable SIP: Boot into Recovery Mode → Terminal → csrutil disable → Reboot"
    echo "⚠ This reduces system security - only do this for development/testing!"
else
    echo "⚠ Note: You may need to disable System Integrity Protection (SIP) for unsigned kexts"
fi
echo "⚠ For production use, please sign the kexts with your Developer ID certificate"

echo ""
echo "*** Build completed successfully! ***" 