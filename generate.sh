# # download this file to your project folder and execute
# # chmod +x generate.sh
# # then run using
# # ./generate.sh

# # flutter build defaults to --release
# flutter build ios --profile  lib/main.dart

# # make folder, add .app then zip it and rename it to .ipa
# mkdir -p Payload
# mv ./build/ios/iphoneos/Runner.app Payload
# zip -r -y Payload.zip Payload/Runner.app
# mv Payload.zip Payload.ipa

# # the following are options, remove Payload folder
# rm -Rf Payload
# # open finder and manually find the .ipa and upload to Diawi using chrome


#!/bin/bash

# Function to convert string to uppercase
to_uppercase() {
    echo "$1" | tr '[:lower:]' '[:upper:]'
}

# Check if build target is provided
if [ -z "$1" ]; then
    echo "Usage: ./generate.sh <build_target>"
    exit 1
fi

# Set variables
BUILD_TARGET=$1



if [[ "$BUILD_TARGET" != "all" && "$BUILD_TARGET" != "ios" && "$BUILD_TARGET" != "apk" ]]; then
    echo "Invalid build target. Allowed values are: ios, apk, all."
    exit 1
fi


# Perform common Flutter commands
flutter clean
flutter pub get && flutter gen-l10n

# Function for building iOS
build_ios() {
    echo "Running Pre build commands for iOS"
    cd ios
    pod install
    cd ..
    echo "Building for....IOS"
    flutter build ios --profile lib/main.dart
    mkdir -p Payload
    mv ./build/ios/iphoneos/Runner.app Payload
    zip -r -y Payload.zip Payload/Runner.app
    mv Payload.zip Payload.ipa
    rm -Rf Payload
}



# Function for building Android
build_android() {
    echo "Building for ... android"
    flutter build apk --release -t lib/main.dart
    mv ./build/app/outputs/flutter-apk/app-release.apk rinsr_delivery.apk
}

# Main build process
case "$BUILD_TARGET" in

    all)
      build_ios
      build_android
      ;;
    ios)
        build_ios
        ;;
    *)
        build_android
        ;;
esac


# ./generate.sh apk