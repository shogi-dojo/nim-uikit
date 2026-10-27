# nim-uikit

Typed Nim bindings to UIKit over the Objective-C runtime. Message sends go
through `objc_msgSend`, cast to the C signature at each call site, so no
Objective-C or Swift source is needed.

Status: early. The runtime, Foundation helpers and block literals are here;
the UIKit classes are added as the Desk Remote app needs them.

MIT licensed.
