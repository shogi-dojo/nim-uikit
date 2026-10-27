## Compile-only check: the bindings must build for the iPhoneOS SDK.
import ../src/uikit/runtime
import ../src/uikit/foundation
import ../src/uikit/ui

proc main() =
  discard nsString("hello")
  discard cls("NSObject")
  discard rect(0, 0, 10, 10)
  discard newWindow(screenBounds())
  autoreleasepool:
    let obj = retain(new(cls("NSObject")))
    release(obj)
    observe(obj, "description", "UIApplicationWillEnterForegroundNotification")
  afterDelay(1.0, proc (context: pointer) {.cdecl.} = discard)

main()
