# nim-uikit

Typed Nim bindings to UIKit over the Objective-C runtime. Each message send goes
through `objc_msgSend`, cast to the C signature at its call site, so an app is
Nim code with a few lines of C for `main`. No Objective-C or Swift source is
needed.

**Status: early.** The runtime, Foundation helpers, the UIKit views and labels
the examples use, and the block literals that `NSURLSession` callbacks need are
in. The bindings are compile-checked against the iPhoneOS 26.2 SDK. They have
not been run on a device or a simulator yet.

MIT licensed.

## Layout

- `src/uikit/runtime.nim`: classes, selectors, `send0`..`send4` for typed sends,
  and `newClass`/`addMethod`/`register` for Nim-defined classes.
- `src/uikit/foundation.nim`: `NSString` conversion, the main dispatch queue,
  and `globalBlock` for capture-free block literals.
- `src/uikit/ui.nim`: `UIView`, `UILabel`, `UIButton`, `UITextField`,
  `UITableView`, `UINavigationController`, `UIWindow`, colours and fonts, and
  `applicationMain`.
- `examples/hello`: a one-screen app in Nim. `build.sh` builds it for a device.
- `examples/hello-swift`: the same screen in Swift, for the comparison below.
- `tests/`: compile-only checks against the iPhoneOS SDK.

## Build and test

    nimble test          # compile-only checks for arm64 iOS, no device needed
    sh examples/hello/build.sh   # bin/hello/Hello.app, fake-signed with ldid

Xcode is found through `XCODE_DIR` (default `/Applications/Xcode.app/Contents/Developer`),
which is passed to `xcrun` directly, so `xcode-select` is not changed.

## Writing an app

    proc helloDidLoad(self: ID, cmd: SEL) {.cdecl.} =
      let root = view(self)
      setBackgroundColor(root, systemBackground())
      let title = newLabel(rect(16, 200, bounds(root).size.width - 32, 120))
      setText(title, "Hello from Nim")
      addSubview(root, title)

Methods that UIKit calls are plain `{.cdecl.}` procs. `addMethod` takes the
Objective-C type encoding for each, for example `"v@:"` for `-(void)viewDidLoad`.
`examples/hello/hello.nim` is the full example.

## Nim vs Swift

The comparison app is the hello screen above, in both languages. Both are built
for arm64 iOS 15.0 with optimisation on. Numbers are from this Mac, on Xcode 26.2.

| | Nim (`examples/hello`) | Swift (`examples/hello-swift`) |
|---|---|---|
| Source lines, excluding comments and blanks | 26 | 25 |
| Binary size | 152,560 bytes | 108,464 bytes |
| Build time, warm | about 0.4 s | about 0.4 s |
| Build time, first build after a clean | not measured | about 3 s |
| Launch time on the SE (iOS 15) | pending device | pending device |
| Scroll smoothness on the SE | pending device | pending device |

The Nim binary is larger because it carries the Nim runtime. The launch and
scroll rows need the phone, and they stay empty until someone measures them.

### Friction hit so far

- **No compile-time selector checking.** A wrong selector string is a runtime
  crash, not a build error. The bindings only check the argument types.
- **Type encodings are written by hand.** Each `addMethod` needs its Objective-C
  encoding, and a wrong one fails silently until UIKit calls it.
- **Blocks must be static.** NSURLSession's callbacks are block literals. They
  have to be globals with no captures, so state lives in module variables.
- **Foundation headers do not compile as C.** The package declares the few
  Objective-C functions it needs without importing the headers.
- **Callbacks run on foreign threads.** NSURLSession calls back on its own
  threads, which Nim must register with `setupForeignThreadGC` before it
  allocates there.
- **No ARC.** Objects created with `new` are owned by the caller and are never
  released, so long-lived objects leak by design. Per-screen controllers are
  the main leak; the app creates one per chat opened.
- **No Interface Builder, no storyboards.** Every view is built in code, so
  layout is manual or uses Auto Layout anchors.

## Licence

MIT. See `LICENSE`.
