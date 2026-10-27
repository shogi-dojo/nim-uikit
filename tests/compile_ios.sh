#!/bin/sh
# Compile-only checks for arm64 iOS against the iPhoneOS SDK. No simulator or device needed.
set -e
cd "$(dirname "$0")/.."
XCODE=${XCODE_DIR:-/Applications/Xcode.app/Contents/Developer}
SDK=$(DEVELOPER_DIR=$XCODE xcrun --sdk iphoneos --show-sdk-path)
CC=$(DEVELOPER_DIR=$XCODE xcrun --sdk iphoneos --find clang)
for module in tests/compile_ios.nim examples/hello/hello.nim; do
  echo "compiling $module"
  nim c --os:ios --cpu:arm64 --app:staticlib --noMain --mm:orc --threads:on --compileOnly \
    --path:src --nimcache:bin/nimcache --clang.exe:"$CC" \
    --passC:"-target arm64-apple-ios15.0 -isysroot $SDK" "$module"
done
