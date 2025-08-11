#!/bin/bash

DEV_NAME=`echo | grep DEVELOPER_NAME DeveloperSettings.xcconfig`
DEV_TEAM=`echo | grep DEVELOPMENT_TEAM DeveloperSettings.xcconfig`
CERT_ID="${DEV_NAME//\DEVELOPER_NAME = } (${DEV_TEAM//\DEVELOPMENT_TEAM = })"

mkdir -p build
zip -r build/360ControllerSource.zip * -x "build*"

echo "Building for architectures: $(uname -m)"
echo "Target architectures: $(xcrun -show-sdk-path | grep -o 'macosx[0-9.]*' | head -1)"

xcrun xcodebuild -configuration Release -target "Whole Driver" -xcconfig "DeveloperSettings.xcconfig" OTHER_CODE_SIGN_FLAGS="--timestamp --options=runtime"
if [ $? -ne 0 ]
  then
    echo "******** BUILD FAILED ********"
    exit 1
fi

cd Install360Controller
packagesbuild -v Install360Controller.pkgproj --identity "Developer ID Installer: ""${CERT_ID}"
mv build 360ControllerInstall
hdiutil create -srcfolder 360ControllerInstall -fs HFS+ -format UDZO ../build/360ControllerInstall.dmg
mv 360ControllerInstall build
cd ..
echo "** File contents **"
echo "Checking 360Controller.kext architecture:"
xcrun lipo -info build/Release/360Controller.kext/Contents/MacOS/360Controller
echo "Checking Feedback360.plugin architecture:"
xcrun lipo -info build/Release/360Controller.kext/Contents/PlugIns/Feedback360.plugin/Contents/MacOS/Feedback360
echo "Checking 360Daemon.app architecture:"
xcrun lipo -info build/Release/360Daemon.app/Contents/MacOS/360Daemon
echo "Checking Pref360Control.prefPane architecture:"
xcrun lipo -info build/Release/Pref360Control.prefPane/Contents/MacOS/Pref360Control
echo "Checking DriverTool architecture:"
xcrun lipo -info build/Release/Pref360Control.prefPane/Contents/Resources/DriverTool
# xcrun lipo -info build/Release/WirelessGamingReceiver.kext/Contents/MacOS/WirelessGamingReceiver
# xcrun lipo -info build/Release/Wireless360Controller.kext/Contents/MacOS/Wireless360Controller
echo "** File signatures **"
xcrun spctl -a -v build/Release/360Controller.kext
xcrun spctl -a -v build/Release/360Controller.kext/Contents/PlugIns/Feedback360.plugin
xcrun spctl -a -v build/Release/360Daemon.app/Contents/MacOS/360Daemon
xcrun spctl -a -v build/Release/Pref360Control.prefPane
xcrun spctl -a -v build/Release/Pref360Control.prefPane/Contents/Resources/DriverTool
# xcrun spctl -a -v build/Release/WirelessGamingReceiver.kext
# xcrun spctl -a -v build/Release/Wireless360Controller.kext
xcrun spctl -a -v --type install Install360Controller/build/Install360Controller.pkg
echo "*** DONE ***"
