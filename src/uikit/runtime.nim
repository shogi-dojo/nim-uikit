## The Objective-C runtime, reached through `objc_msgSend`.
##
## Message sends are typed: `send0`..`send4` take the receiver, the selector
## and up to four arguments, and cast `objc_msgSend` to the matching C
## signature. Arguments and results must be pointer-sized, integer, float or
## a plain C struct; that covers UIKit's calls on arm64 without `_stret`.

type
  ID* = pointer
  SEL* = pointer
  Class* = pointer
  IMP* = pointer
  BOOL* = int8

proc objc_msgSend() {.importc, cdecl.}
proc objc_getClass(name: cstring): Class {.importc, cdecl.}
proc sel_registerName(name: cstring): SEL {.importc, cdecl.}
proc objc_allocateClassPair(superclass: Class, name: cstring, extra: csize_t): Class {.importc, cdecl.}
proc objc_registerClassPair(cls: Class) {.importc, cdecl.}
proc class_addMethod(cls: Class, name: SEL, imp: IMP, types: cstring): BOOL {.importc, cdecl.}
proc class_addProtocol(cls: Class, protocol: pointer): BOOL {.importc, cdecl.}
proc objc_getProtocol(name: cstring): pointer {.importc, cdecl.}

proc cls*(name: cstring): Class =
  ## The class named `name`; nil when it does not exist.
  objc_getClass(name)

proc sel*(name: cstring): SEL =
  ## The selector named `name`, for example "setText:".
  sel_registerName(name)

proc send0*[R](self: ID, s: SEL): R =
  cast[proc(self: ID, cmd: SEL): R {.cdecl.}](objc_msgSend)(self, s)

proc send1*[R, A](self: ID, s: SEL, a: A): R =
  cast[proc(self: ID, cmd: SEL, a: A): R {.cdecl.}](objc_msgSend)(self, s, a)

proc send2*[R, A, B](self: ID, s: SEL, a: A, b: B): R =
  cast[proc(self: ID, cmd: SEL, a: A, b: B): R {.cdecl.}](objc_msgSend)(self, s, a, b)

proc send3*[R, A, B, C](self: ID, s: SEL, a: A, b: B, c: C): R =
  cast[proc(self: ID, cmd: SEL, a: A, b: B, c: C): R {.cdecl.}](objc_msgSend)(self, s, a, b, c)

proc send4*[R, A, B, C, D](self: ID, s: SEL, a: A, b: B, c: C, d: D): R =
  cast[proc(self: ID, cmd: SEL, a: A, b: B, c: C, d: D): R {.cdecl.}](objc_msgSend)(self, s, a, b, c, d)

proc newClass*(name: cstring, super: Class): Class =
  ## A new class named `name` inheriting from `super`. Add methods, then `register`.
  objc_allocateClassPair(super, name, 0)

proc addMethod*(cls: Class, name: cstring, imp: pointer, types: cstring) =
  ## Add a method implemented by the Nim proc behind `imp`. `types` is the
  ## Objective-C type encoding, for example "v@:@" for `-(void)foo:(id)x`.
  discard class_addMethod(cls, sel(name), imp, types)

proc addProtocol*(cls: Class, name: cstring) =
  discard class_addProtocol(cls, objc_getProtocol(name))

proc register*(cls: Class) =
  objc_registerClassPair(cls)

proc alloc*(cls: Class): ID =
  send0[ID](cls, sel("alloc"))

proc init*(obj: ID): ID =
  send0[ID](obj, sel("init"))

proc new*(cls: Class): ID =
  ## `[[cls alloc] init]`: an owned object the caller keeps alive.
  send0[ID](cls, sel("new"))
