# 360Controller Build Options Guide

This guide explains all the available build options for the 360Controller driver, depending on your system configuration and needs.

## 🚀 Quick Start

Choose the build script that matches your setup:

| System | Build Script | Description |
|--------|--------------|-------------|
| **Apple Silicon + Full Xcode** | `./build_apple_silicon.sh` | ✅ **Recommended** - Full functionality |
| **Apple Silicon + Command Line Tools** | `./build_cli.sh` | ⚠️ Limited - Shows next steps |
| **Intel Mac + Full Xcode** | `./build.sh` | ✅ Full functionality |
| **Intel Mac + Command Line Tools** | `./build_cli.sh` | ⚠️ Limited - Shows next steps |

## 📱 Apple Silicon (M1/M2) Macs

### Option 1: Full Xcode (Recommended)
```bash
./build_apple_silicon.sh
```
**What it does:**
- Builds universal binaries (ARM64 + x86_64)
- Creates installer package
- Handles code signing
- Full Apple Silicon optimization

**Requirements:**
- Xcode 14.0+ from Mac App Store
- macOS 12.0+ for building
- macOS 11.0+ for running

### Option 2: Command Line Tools Only
```bash
./build_cli.sh
```
**What it does:**
- Detects your system configuration
- Explains what's needed
- Shows alternative build methods
- Guides you to install full Xcode

**Requirements:**
- Command Line Tools for Xcode
- Will guide you to install full Xcode

## 🖥️ Intel Macs

### Option 1: Full Xcode
```bash
./build.sh
```
**What it does:**
- Builds for Intel architecture
- Creates installer package
- Handles code signing
- Traditional build process

**Requirements:**
- Xcode 14.0+ from Mac App Store
- macOS 12.0+ for building
- macOS 11.0+ for running

### Option 2: Command Line Tools Only
```bash
./build_cli.sh
```
**What it does:**
- Same as Apple Silicon CLI version
- Explains limitations
- Guides to full Xcode installation

## 🔧 Manual Build Options

### Xcode IDE
```bash
open "360 Driver.xcworkspace"
```
**Best for:**
- Development and debugging
- Visual project management
- Step-by-step building

### Command Line (Full Xcode)
```bash
xcrun xcodebuild -configuration Release -target "Whole Driver" -xcconfig "DeveloperSettings.xcconfig"
```
**Best for:**
- Automated builds
- CI/CD pipelines
- Headless systems

### Individual Component Builds
If you only have Command Line Tools, you can try building individual components:

```bash
# Build 360Controller core
cd 360Controller
clang++ -framework IOKit -framework CoreFoundation _60Controller.cpp Controller.cpp -o 360Controller

# Build Feedback360 plugin
cd Feedback360
clang -framework IOKit -framework CoreFoundation Feedback360.cpp -o Feedback360
```

**Note:** This is experimental and may not work for all components.

## 📋 System Requirements Summary

| Component | Building | Running |
|-----------|----------|---------|
| **Full Xcode** | ✅ Required | ❌ Not needed |
| **Command Line Tools** | ⚠️ Limited | ❌ Not needed |
| **macOS Version** | 12.0+ | 11.0+ |
| **Architecture** | ARM64 + x86_64 | ARM64 + x86_64 |

## 🚨 Common Issues & Solutions

### "xcodebuild not found"
**Problem:** Only Command Line Tools installed
**Solution:** Install full Xcode from Mac App Store

### "Architecture not supported"
**Problem:** Old project configuration
**Solution:** Use updated build scripts (already done in this project)

### "Kext cannot be loaded"
**Problem:** System Integrity Protection (SIP) enabled
**Solution:** Temporarily disable SIP for development/testing

### "Build failed"
**Problem:** Missing dependencies or configuration
**Solution:** Check `DeveloperSettings.xcconfig` and ensure Xcode is up to date

## 🎯 Recommended Workflow

1. **Start with:** `./build_cli.sh` to assess your system
2. **If CLI only:** Install full Xcode from Mac App Store
3. **After Xcode:** Use `./build_apple_silicon.sh` (Apple Silicon) or `./build.sh` (Intel)
4. **For development:** Use Xcode IDE for debugging and iteration

## 📚 Additional Resources

- **Apple Silicon Guide:** [APPLE_SILICON_README.md](APPLE_SILICON_README.md)
- **Main Documentation:** [Readme.md](Readme.md)
- **Project Structure:** [360 Driver.xcodeproj](360%20Driver.xcodeproj)

## 🔄 Build Script Comparison

| Feature | `build_apple_silicon.sh` | `build_cli.sh` | `build.sh` |
|---------|--------------------------|----------------|------------|
| **Apple Silicon Support** | ✅ Full | ✅ Detection | ⚠️ Limited |
| **Universal Binary** | ✅ Yes | ❌ No | ❌ No |
| **Xcode Required** | ✅ Yes | ❌ No | ✅ Yes |
| **Installer Package** | ✅ Yes | ❌ No | ✅ Yes |
| **Code Signing** | ✅ Yes | ❌ No | ✅ Yes |
| **Architecture Detection** | ✅ Yes | ✅ Yes | ❌ No |

---

**Last Updated:** December 2024  
**Project Version:** 0.16.12+  
**Apple Silicon Support:** ✅ Added  
**Universal Binary:** ✅ Yes 