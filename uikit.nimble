version       = "0.1.0"
author        = "shogi-dojo"
description   = "Typed Nim bindings to UIKit over the Objective-C runtime"
license       = "MIT"
srcDir        = "src"

requires "nim >= 2.2.0"

task test, "Compile the bindings for the iPhoneOS SDK":
  exec "sh tests/compile_ios.sh"
