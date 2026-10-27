## Hello, UIKit: the smallest app that uses nim-uikit. One screen, one label.
## main.m calls `hello_main`, which registers the classes and runs UIKit.

import uikit/runtime
import uikit/foundation
import uikit/ui

proc helloDidLoad(self: ID, cmd: SEL) {.cdecl.} =
  let root = view(self)
  setBackgroundColor(root, systemBackground())
  let title = newLabel(rect(16, 200, bounds(root).size.width - 32, 120))
  setText(title, "Hello from Nim")
  setTextColor(title, label())
  setFont(title, systemFont(28))
  setNumberOfLines(title, 0)
  addSubview(root, title)

proc appDidFinish(self: ID, cmd: SEL, app: ID, options: ID): int8 {.cdecl.} =
  let window = newWindow(screenBounds())
  setRootViewController(window, new(cls("HelloVC")))
  makeKeyAndVisible(window)
  1

proc hello_main*(argc: cint, argv: pointer): cint {.exportc, cdecl.} =
  let delegate = newClass("HelloDelegate", cls("UIResponder"))
  addMethod(delegate, "application:didFinishLaunchingWithOptions:",
            cast[pointer](appDidFinish), "B@:@@")
  register(delegate)
  let controller = newClass("HelloVC", cls("UIViewController"))
  addMethod(controller, "viewDidLoad", cast[pointer](helloDidLoad), "v@:")
  register(controller)
  applicationMain(argc, argv, nil, nsString("HelloDelegate"))
