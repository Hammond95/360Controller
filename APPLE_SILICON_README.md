# 360Controller for Apple Silicon (M1/M2) Macs

This document provides instructions for building and using the 360Controller driver on Apple Silicon Macs running macOS Sequoia and later.

## What's New for Apple Silicon

The 360Controller project has been updated to support Apple Silicon (ARM64) architecture while maintaining compatibility with Intel (x86_64) Macs. Key changes include:

- **Universal Binary Support**: All components now build as universal binaries supporting both ARM64 and x86_64
- **Modern SDK**: Updated to use the latest macOS SDK instead of the outdated 10.10 SDK
- **Deployment Target**: Updated to macOS 11.0 (Big Sur) minimum for better compatibility
- **Apple Silicon Optimized**: Build scripts and configurations optimized for M1/M2 Macs

## Prerequisites

### Required Software
- **Xcode 14.0 or later** (available from the Mac App Store)
- **macOS 12.0 (Monterey) or later** for building
- **macOS 11.0 (Big Sur) or later** for running the driver

### Optional Software
- **Packages.app** for creating installer packages
- **Developer ID Certificate** for code signing and distribution

## Building the Driver

### Quick Build (Recommended for Apple Silicon)

Use the optimized build script specifically designed for Apple Silicon:

```bash
./build_apple_silicon.sh
```

This script will:
- Detect your system architecture
- Create necessary configuration files
- Build universal binaries for both ARM64 and x86_64
- Verify architecture support
- Create an installer package (if Packages.app is available)

### Manual Build

If you prefer to build manually or need to customize the build process:

1. **Open the project in Xcode:**
   ```bash
   open "360 Driver.xcworkspace"
   ```

2. **Select the "Whole Driver" target** and build for Release configuration

3. **Or use the command line:**
   ```bash
   xcrun xcodebuild -configuration Release -target "Whole Driver" -xcconfig "DeveloperSettings.xcconfig"
   ```

## Configuration

### DeveloperSettings.xcconfig

The project now includes a `DeveloperSettings.xcconfig` file that you should customize:

```xcconfig
DEVELOPMENT_TEAM = YOUR_TEAM_ID
DEVELOPER_NAME = Your Name
DEVELOPER_EMAIL = your.email@example.com
NOTARIZATION_PASSWORD = your-app-specific-password
```

**For development/testing only**, you can leave these as placeholder values.

## Installation

### Method 1: Installer Package (Recommended)

If you built with the installer package:

1. Double-click the generated `360ControllerInstall.dmg`
2. Run the installer package
3. Restart your Mac

### Method 2: Manual Installation

1. **Copy the kernel extension:**
   ```bash
   sudo cp -R build/Release/360Controller.kext /Library/Extensions/
   ```

2. **Copy the preference pane:**
   ```bash
   cp -R build/Release/Pref360Control.prefPane ~/Library/PreferencePanes/
   ```

3. **Copy the daemon app:**
   ```bash
   cp -R build/Release/360Daemon.app /Applications/
   ```

4. **Load the kernel extension:**
   ```bash
   sudo kextload /Library/Extensions/360Controller.kext
   ```

## System Requirements

### For Building
- macOS 12.0 (Monterey) or later
- Xcode 14.0 or later
- Command Line Tools for Xcode

### For Running
- macOS 11.0 (Big Sur) or later
- Xbox 360 controller (wired or wireless)
- Xbox One controller (wired or wireless)

## Troubleshooting

### Common Issues

#### "Kext cannot be loaded" Error
This usually means System Integrity Protection (SIP) is enabled. For development/testing:

1. **Boot into Recovery Mode** (hold Cmd+R during startup)
2. **Open Terminal** from Utilities menu
3. **Disable SIP:**
   ```bash
   csrutil disable
   ```
4. **Reboot** and try loading the kext again

**⚠️ Warning**: Disabling SIP reduces system security. Only do this for development/testing.

#### "Architecture not supported" Error
Ensure you're using the updated build scripts and Xcode project. The driver should now build as a universal binary supporting both ARM64 and x86_64.

#### Build Failures
- Ensure Xcode is up to date
- Check that all required frameworks are available
- Verify the `DeveloperSettings.xcconfig` file exists and is properly formatted

### Debugging

#### Kernel Extension Logs
View kernel extension logs in Console.app or use:
```bash
log show --predicate 'process == "kernel"' --last 5m
```

#### Driver Tool
Use the included DriverTool to test controller connectivity:
```bash
sudo /Library/Extensions/360Controller.kext/Contents/Resources/DriverTool
```

## Code Signing and Distribution

### For Development/Testing
- Use the project as-is with unsigned builds
- Disable SIP temporarily for testing

### For Production Distribution
1. **Obtain a Developer ID Certificate** from Apple
2. **Update `DeveloperSettings.xcconfig`** with your certificate details
3. **Build with code signing enabled**
4. **Notarize the driver** using Apple's notarization service
5. **Staple the notarization ticket** to the driver

## Architecture Support

The updated driver now supports:

- **ARM64 (Apple Silicon)**: Native support for M1/M2 Macs
- **x86_64 (Intel)**: Continued support for Intel Macs
- **Universal Binary**: Single binary supporting both architectures

## Performance Notes

- **Apple Silicon**: The driver runs natively on ARM64, providing optimal performance
- **Rosetta 2**: Intel Macs can run the ARM64 version through Rosetta 2 if needed
- **Memory Usage**: Universal binaries are slightly larger but provide maximum compatibility

## Contributing

When contributing to the project:

1. **Test on both architectures** when possible
2. **Use the updated build scripts** for Apple Silicon compatibility
3. **Maintain universal binary support** for all new components
4. **Update this document** for any new Apple Silicon-specific features

## Support

For issues specific to Apple Silicon:

1. Check this document first
2. Verify you're using the latest version
3. Test with the provided build scripts
4. Report issues with system information (architecture, macOS version, Xcode version)

## License

This project is licensed under the GNU Public License. See `Licence.txt` for details.

---

**Last Updated**: December 2024
**Apple Silicon Support**: Added in version 0.16.12+
**Minimum macOS**: 11.0 (Big Sur)
**Architecture Support**: ARM64 + x86_64 (Universal Binary) 