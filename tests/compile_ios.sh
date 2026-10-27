#!/bin/sh
# Compile the bindings for arm64 iOS against the iPhoneOS SDK (no simulator needed).
set -e
XCODE=${XCODE_DIR:-/Applications/Xcode.app/Contents/Developer}
SDK=$(DEVELOPER_DIR=$XCODE xcrun --sdk iphoneos --show-sdk-path)
CC=$(DEVELOPER_DIR=$XCODE xcrun --sdk iphoneos --find clang)
nim c --os:ios --cpu:arm64 --app:staticlib --noMain --mm:orc --threads:on --compileOnly \
  --nimcache:bin/nimcache --clang.exe:"$CC" \
  --passC:"-target arm64-apple-ios15.0 -isysroot $SDK" \
  tests/compile_ios.nim
