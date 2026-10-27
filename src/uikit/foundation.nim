## Foundation helpers: strings, the main queue and the block literal that
## NSURLSession hands its completion handlers.

import ./runtime

proc nsString*(s: string): ID =
  ## An autoreleased NSString copied from `s`.
  send1[ID, cstring](cls("NSString"), sel("stringWithUTF8String:"), cstring(s))

proc fromNSString*(obj: ID): string =
  ## The UTF-8 text of an NSString; empty for nil.
  if obj == nil:
    return ""
  let text = send0[cstring](obj, sel("UTF8String"))
  if text == nil: "" else: $text

type
  DispatchFn* = proc (context: pointer) {.cdecl.}

var dispatchMainQueue {.importc: "_dispatch_main_q", header: "<dispatch/dispatch.h>", nodecl.}: pointer

proc dispatch_async_f(queue: pointer, context: pointer, work: DispatchFn)
  {.importc, header: "<dispatch/dispatch.h>", nodecl.}

proc onMainQueue*(work: DispatchFn) =
  ## Run `work` on the main thread, after the current call returns.
  dispatch_async_f(addr dispatchMainQueue, nil, work)

proc dispatch_time(base: uint64, delta: int64): uint64
  {.importc, header: "<dispatch/dispatch.h>", nodecl.}
proc dispatch_after_f(time: uint64, queue: pointer, context: pointer, work: DispatchFn)
  {.importc, header: "<dispatch/dispatch.h>", nodecl.}

proc afterDelay*(seconds: float, work: DispatchFn) =
  ## Run `work` on the main thread `seconds` from now.
  dispatch_after_f(dispatch_time(0, int64(seconds * 1e9)), addr dispatchMainQueue,
                   nil, work)

proc observe*(target: ID, action: cstring, name: string) =
  ## Send `action` to `target` whenever the notification `name` is posted,
  ## for example "UIApplicationWillEnterForegroundNotification".
  let center = send0[ID](cls("NSNotificationCenter"), sel("defaultCenter"))
  send4[void, ID, SEL, ID, ID](center, sel("addObserver:selector:name:object:"),
                              target, sel(action), nsString(name), nil)

# A block literal without captures, placed in static storage so no copy is
# needed. Its `invoke` receives the block pointer first, then the arguments.
type
  BlockDescriptor* = object
    reserved*: culong
    size*: culong

  BlockLiteral* = object
    isa: pointer
    flags: cint
    reserved: cint
    invoke: pointer
    descriptor: ptr BlockDescriptor

var concreteGlobalBlock {.importc: "_NSConcreteGlobalBlock", header: "<Block.h>", nodecl.}: array[32, pointer]

const blockIsGlobal = 1 shl 28

proc globalBlock*(invoke: pointer, descriptor: ptr BlockDescriptor): BlockLiteral =
  ## A block literal for `invoke`, with no captures, living in static storage.
  BlockLiteral(isa: addr concreteGlobalBlock, flags: blockIsGlobal, reserved: 0,
               invoke: invoke, descriptor: descriptor)


proc NSHomeDirectory(): ID {.importc, cdecl.}

proc homeDirectory*(): string =
  ## The app's sandbox root, from NSHomeDirectory.
  fromNSString(NSHomeDirectory())
