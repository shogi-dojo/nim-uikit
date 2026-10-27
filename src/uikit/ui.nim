## The UIKit classes the Desk Remote app uses, as typed procs over `send*`.
## Every proc takes the object it messages first, so calls read like the
## Objective-C they replace: `view.addSubview(label)`.

import ./runtime
import ./foundation

type
  CGPoint* = object
    x*, y*: float64
  CGSize* = object
    width*, height*: float64
  CGRect* = object
    origin*: CGPoint
    size*: CGSize

  UIEdgeInsets* = object
    top*, left*, bottom*, right*: float64

const
  UIViewAutoresizeWidthHeight* = 2 or 16   ## FlexibleWidth | FlexibleHeight
  UIControlEventTouchUpInside* = 64'u
  UIControlStateNormal* = 0'u
  UIButtonTypeSystem* = 1
  UITableViewStylePlain* = 0
  UITableViewStyleGrouped* = 1
  UITableViewCellStyleSubtitle* = 3
  UITextBorderStyleRoundedRect* = 3
  UIAlertControllerStyleAlert* = 1
  UIAlertControllerStyleActionSheet* = 0

proc rect*(x, y, width, height: float64): CGRect =
  CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))

proc alloc*(name: string): ID =
  ## `[[Name alloc] init]`, for classes whose init takes no arguments.
  cls(name).alloc().init()

# UIView and UIResponder

proc setFrame*(view: ID, frame: CGRect) =
  send1[void, CGRect](view, sel("setFrame:"), frame)

proc frame*(view: ID): CGRect =
  send0[CGRect](view, sel("frame"))

proc bounds*(view: ID): CGRect =
  send0[CGRect](view, sel("bounds"))

proc addSubview*(view, child: ID) =
  send1[void, ID](view, sel("addSubview:"), child)

proc setBackgroundColor*(view, color: ID) =
  send1[void, ID](view, sel("setBackgroundColor:"), color)

proc setAutoresizingMask*(view: ID, mask: uint) =
  send1[void, uint](view, sel("setAutoresizingMask:"), mask)

proc setTranslatesAutoresizingMask*(view: ID, on: bool) =
  send1[void, BOOL](view, sel("setTranslatesAutoresizingMaskIntoConstraints:"), BOOL(ord(on)))

proc view*(controller: ID): ID =
  send0[ID](controller, sel("view"))

proc setTag*(view: ID, tag: int) =
  send1[void, int](view, sel("setTag:"), tag)

proc tag*(view: ID): int =
  send0[int](view, sel("tag"))

# Colours and fonts

proc systemBackground*(): ID =
  send0[ID](cls("UIColor"), sel("systemBackgroundColor"))

proc label*(): ID =
  send0[ID](cls("UIColor"), sel("labelColor"))

proc secondaryLabel*(): ID =
  send0[ID](cls("UIColor"), sel("secondaryLabelColor"))

proc systemGreen*(): ID =
  send0[ID](cls("UIColor"), sel("systemGreenColor"))

proc systemOrange*(): ID =
  send0[ID](cls("UIColor"), sel("systemOrangeColor"))

proc systemRed*(): ID =
  send0[ID](cls("UIColor"), sel("systemRedColor"))

proc systemGray*(): ID =
  send0[ID](cls("UIColor"), sel("systemGrayColor"))

proc systemFont*(size: float64): ID =
  send1[ID, float64](cls("UIFont"), sel("systemFontOfSize:"), size)

# UILabel

proc newLabel*(frame: CGRect): ID =
  send1[ID, CGRect](cls("UILabel").alloc(), sel("initWithFrame:"), frame)

proc setText*(view: ID, text: string) =
  send1[void, ID](view, sel("setText:"), nsString(text))

proc setTextColor*(view, color: ID) =
  send1[void, ID](view, sel("setTextColor:"), color)

proc setFont*(view, font: ID) =
  send1[void, ID](view, sel("setFont:"), font)

proc setNumberOfLines*(view: ID, lines: int) =
  send1[void, int](view, sel("setNumberOfLines:"), lines)

# UIControl and UIButton

proc newButton*(): ID =
  send1[ID, int](cls("UIButton"), sel("buttonWithType:"), UIButtonTypeSystem)

proc setButtonTitle*(button: ID, title: string) =
  send2[void, ID, uint](button, sel("setTitle:forState:"), nsString(title), UIControlStateNormal)

proc addTouchTarget*(control, target: ID, action: cstring) =
  ## Send `action` to `target` when `control` is tapped.
  send3[void, ID, SEL, uint](control, sel("addTarget:action:forControlEvents:"),
                             target, sel(action), UIControlEventTouchUpInside)

# UITextField

proc newTextField*(frame: CGRect): ID =
  send1[ID, CGRect](cls("UITextField").alloc(), sel("initWithFrame:"), frame)

proc text*(field: ID): string =
  fromNSString(send0[ID](field, sel("text")))

proc setPlaceholder*(field: ID, text: string) =
  send1[void, ID](field, sel("setPlaceholder:"), nsString(text))

proc setBorderStyle*(field: ID, style: int) =
  send1[void, int](field, sel("setBorderStyle:"), style)

proc setDelegate*(view, delegate: ID) =
  send1[void, ID](view, sel("setDelegate:"), delegate)

proc clearText*(field: ID) =
  send1[void, ID](field, sel("setText:"), nil)

# UITableView and UITableViewCell

proc newTableView*(frame: CGRect, style: int): ID =
  send2[ID, CGRect, int](cls("UITableView").alloc(), sel("initWithFrame:style:"), frame, style)

proc setDataSource*(view, source: ID) =
  send1[void, ID](view, sel("setDataSource:"), source)

proc reloadData*(view: ID) =
  send0[void](view, sel("reloadData"))

proc newCell*(style: int, reuse: string): ID =
  send2[ID, int, ID](cls("UITableViewCell").alloc(), sel("initWithStyle:reuseIdentifier:"),
                     style, nsString(reuse))

proc textLabel*(cell: ID): ID =
  send0[ID](cell, sel("textLabel"))

proc detailTextLabel*(cell: ID): ID =
  send0[ID](cell, sel("detailTextLabel"))

proc contentView*(cell: ID): ID =
  send0[ID](cell, sel("contentView"))

# UINavigationController and UIWindow

proc newNavigationController*(root: ID): ID =
  send1[ID, ID](cls("UINavigationController").alloc(), sel("initWithRootViewController:"), root)

proc pushViewController*(nav, controller: ID) =
  send2[void, ID, BOOL](nav, sel("pushViewController:animated:"), controller, BOOL(1))

proc popViewController*(nav: ID) =
  discard send1[ID, BOOL](nav, sel("popViewControllerAnimated:"), BOOL(1))

proc setTitle*(controller: ID, title: string) =
  send1[void, ID](controller, sel("setTitle:"), nsString(title))

proc navigationItem*(controller: ID): ID =
  send0[ID](controller, sel("navigationItem"))

proc setRightBarButton*(item, button: ID) =
  send1[void, ID](item, sel("setRightBarButtonItem:"), button)

proc newWindow*(frame: CGRect): ID =
  send1[ID, CGRect](cls("UIWindow").alloc(), sel("initWithFrame:"), frame)

proc setRootViewController*(window, controller: ID) =
  send1[void, ID](window, sel("setRootViewController:"), controller)

proc makeKeyAndVisible*(window: ID) =
  send0[void](window, sel("makeKeyAndVisible"))

proc screenBounds*(): CGRect =
  send0[CGRect](send0[ID](cls("UIScreen"), sel("mainScreen")), sel("bounds"))

proc applicationMain*(argc: cint, argv: pointer, principal: ID, delegate: ID): cint
  {.importc: "UIApplicationMain", cdecl.}
  ## Runs the UIKit loop. `delegate` is the name of the app delegate class.
