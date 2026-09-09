# SwiftUI Keyboard Manager

Keep your focused input in view — without rewriting your SwiftUI fields.

A small, dependency-free Swift package for keyboard-synchronized vertical scrolling.
Built from a real form used in Native Mobile.

> Initial development release. Build support: iOS 17+, Swift 6, Xcode 16+.
> Keyboard behavior targets iPhone and iPad; macOS uses a plain ScrollView fallback.
> A successful build is not a guarantee across every OS, keyboard, or container.

## Install

In Xcode, choose **File → Add Package Dependencies** and enter:

```text
https://github.com/ShawnBaek/swiftui-keyboard-manager
```

Until the first versioned release, select the **main** branch.
Select the **SwiftUIKeyboardManager** library for your app target.

Or in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ShawnBaek/swiftui-keyboard-manager.git", branch: "main")
]
// In your target:
dependencies: [
    .product(name: "SwiftUIKeyboardManager", package: "swiftui-keyboard-manager")
]
```

## Use your existing SwiftUI inputs

```swift
import SwiftUI
import SwiftUIKeyboardManager

struct ProfileForm: View {
    enum Field: Hashable { case name, notes }
    @State private var name = ""
    @State private var notes = ""
    @FocusState private var focus: Field?

    var body: some View {
        KeyboardManagedScrollView(
            swipeToDismiss: .onDrag,
            keyboardSpacing: 16,
            onDismiss: { focus = nil }
        ) {
            VStack(alignment: .leading, spacing: 24) {
                TextField("Name", text: $name)
                    .focused($focus, equals: .name)
                    .keyboardManagedFocus(focus == .name)

                TextEditor(text: $notes)
                    .frame(height: 180)
                    .focused($focus, equals: .notes)
                    .keyboardManagedFocus(focus == .notes)
            }
            .padding()
        }
    }
}
```

Use the same marker with `SecureField`, a vertical `TextField`, or a custom
SwiftUI input. The package observes the marked view's bounds, not its text.
For a wrapped UIKit `UITextView`, connect its focus state to the same marker.

### Swipe-to-dismiss

| Option | Behavior |
|---|---|
| `.never` | Keep the keyboard while scrolling. |
| `.onDrag` (default) | Clear focus and dismiss when a user starts dragging. |
| `.interactive` | Use UIKit's interactive keyboard dismissal gesture. |

Pass `onDismiss` to clear your SwiftUI `FocusState`.
Programmatic scrolling does not invoke the drag dismissal callback.
`keyboardSpacing` is the requested gap above the keyboard (default: 16 points).

## Container contract

- Replace the outer vertical `ScrollView` or form layout with this container.
  Put a `VStack`, sections, or cards inside it. **Do not nest a Form, List,
  LazyVStack, or another vertical ScrollView** and expect automatic integration.
- Keep navigation destinations, sheets and app-level toolbars outside the
  managed container. Environment values are forwarded to the hosted content.
- Do not add keyboard-height padding or a second keyboard avoidance system.
- A marked editor taller than the viewport keeps its top visible. **Caret-level
  tracking inside a long TextEditor is not implemented.** Its own scrolling
  remains responsible for the insertion point.
- Keyboard accessory/toolbars are owned by the app. This package does not
  create a Done/Next accessory or promise compatibility with every custom bar.
- Floating/split keyboards, external displays, Stage Manager, nested input
  scrolling and interactive cancellation need broader device testing.
- No swizzling, private SwiftUI class lookup, analytics, or network requests.

## How it works

SwiftUI renders the content and input controls. A small owned UIScrollView /
UIHostingController bridge converts the focused marker into scroll-content
coordinates. It compares the marker to the keyboard's converted end frame,
adds only the needed reveal distance, clamps the offset, and changes inset and
offset using the keyboard notification's animation duration and curve.

Apple already provides keyboard safe areas, dismissal modifiers and
UIKeyboardLayoutGuide. This package packages an explicit reveal policy for
SwiftUI forms; it does not claim Apple lacks keyboard support or that keyboard
notifications are the only solution.

- [Apple: Keep up with the keyboard](https://developer.apple.com/videos/play/wwdc2023/10281/)
- [Apple: Keyboard layout guide](https://developer.apple.com/documentation/uikit/adjusting-your-layout-with-keyboard-layout-guide)
- [Apple: SwiftUI keyboard dismissal](https://developer.apple.com/documentation/swiftui/view/scrolldismisseskeyboard(_:))

## Sample app

Open `Examples/KeyboardDemo`, run `xcodegen generate`, and open
`KeyboardDemo.xcodeproj`. Choose an iPhone simulator and run **KeyboardDemo**.
The sample links the local package, so changing the library updates the demo.

The sample covers several fields, a multiline editor, scroll positions and
all three dismissal modes. See [demo evidence](Documentation/Demo.md) for the
recording and the exact verified scope.

## Apps using this library

This is an **opt-in, automatically rendered** showcase, not an SDK tracker.
Private apps and App Store binaries cannot be reliably enumerated from GitHub.

<!-- APPS:START -->
No published integrations registered yet.
<!-- APPS:END -->

Add your app to `Documentation/apps.json` in a pull request with evidence of
adoption. After maintainer review and merge, the showcase workflow renders the
README automatically. Never add an app based only on a code-search guess.
GitHub's dependency graph may show some public dependents; it is not a complete
list of shipping apps.

## Contributing

Please report the OS/device, keyboard type, container structure, a small
reproduction and a short recording. Do not include private typed text.
Run `swift test` for geometry checks and build the sample for UIKit code.
Host-platform tests alone do not compile the iOS bridge.

## License

MIT. See [LICENSE](LICENSE).
