#!/bin/sh
# Build examples/hello into bin/hello/Hello.app and fake-sign it. Needs Xcode and ldid.
set -e
cd "$(dirname "$0")/../.."
XCODE=${XCODE_DIR:-/Applications/Xcode.app/Contents/Developer}
export DEVELOPER_DIR=$XCODE
SDK=$(xcrun --sdk iphoneos --show-sdk-path)
CC=$(xcrun --sdk iphoneos --find clang)
TARGET=arm64-apple-ios15.0
APP=bin/hello/Hello.app
nim c --os:ios --cpu:arm64 --app:staticlib --noMain --mm:orc --threads:on \
  --path:src --nimcache:bin/hello/nimcache --out:bin/hello/libhello.a \
  --clang.exe:"$CC" --clang.linkerexe:"$CC" \
  --passC:"-target $TARGET -isysroot $SDK" --passL:"-target $TARGET -isysroot $SDK" \
  examples/hello/hello.nim
mkdir -p "$APP"
"$CC" -fobjc-arc -target $TARGET -isysroot "$SDK" -framework UIKit -framework Foundation \
  -framework CoreGraphics -Lbin/hello -lhello examples/hello/main.m -o "$APP/Hello"
cp examples/hello/Info.plist "$APP/Info.plist"
ldid -S "$APP/Hello"
echo "built $APP"
