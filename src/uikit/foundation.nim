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

