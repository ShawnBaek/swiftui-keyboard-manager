# SwiftUI Keyboard Manager

Keep your focused input in view — without rewriting your SwiftUI fields.

A small, dependency-free Swift package for keyboard-synchronized vertical scrolling.
Built from a real form used in Native Mobile.

> Initial development release. Build support: iOS 17+, Swift 6, Xcode 16+.
> Keyboard behavior targets iPhone and iPad; macOS uses a plain ScrollView fallback.
> A successful build is not a guarantee across every OS, keyboard, or container.

## See it in action

Real iPhone 17 Pro Simulator recording (iOS 27): focus the lower `TextEditor`,
type with the software keyboard, then drag to dismiss. The sample uses
`.keyboardManager(dismiss: .onDrag)` with 16-point keyboard spacing.

https://github.com/user-attachments/assets/93c56c58-d5f4-4981-a7fa-9710b8a44d15

[Recording and verification details](Documentation/Demo.md)

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
    @State private var name = ""
    @State private var notes = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                TextField("Name", text: $name)

                TextEditor(text: $notes)
                    .frame(height: 180)
            }
            .padding()
        }
        .keyboardManager(dismiss: .onDrag)
    }
}
```

Apply `keyboardManager` directly to a `ScrollView`, before modifiers that erase
its type. The managed vertical path replaces the native scroll view with an
owned `UIScrollView` hosting the public SwiftUI content; it does not introspect
or modify SwiftUI's native scroll view in place.

### Swipe-to-dismiss

| Option | Behavior |
|---|---|
| `.never` | Keep the keyboard while scrolling. |
| `.onDrag` (default) | Clear focus and dismiss when a user starts dragging. |
| `.interactive` | Use UIKit's interactive keyboard dismissal gesture. |

Use `@FocusState` only when your app needs programmatic Next or Done controls.

## Container contract

- Apply the modifier to a vertical `ScrollView` with eager `VStack` content.
  Horizontal or mixed-axis scroll views retain their native scrolling and
  native dismissal behavior. `List`, `Form`, `LazyVStack`, `ScrollViewReader`,
  `scrollPosition`, and other advanced scroll configurations are not supported
  by the managed vertical path.
- Keep navigation destinations, sheets and app-level toolbars outside the
  managed container. Color scheme, Dynamic Type, locale, layout direction and
  enabled state are forwarded. Inject app-specific environment objects/values
  on the content inside the `ScrollView`; do not rely on them crossing the
  UIKit hosting boundary automatically. Copying the entire SwiftUI environment
  can suppress the hosted inputs' accessibility tree.
- Do not add keyboard-height padding or a second keyboard avoidance system.
- A `TextEditor` taller than the viewport keeps its top visible. **Caret-level
  tracking inside a long editor is not implemented.** Its own scrolling remains
  responsible for the insertion point.
- Keyboard accessory/toolbars are owned by the app. This package does not
  create a Done/Next accessory or promise compatibility with every custom bar.
- Floating/split keyboards, external displays, Stage Manager, nested input
  scrolling and interactive cancellation need broader device testing.
- No swizzling, private SwiftUI class lookup, analytics, or network requests.

## How it works

SwiftUI renders the content and input controls. A small owned UIScrollView /
UIHostingController bridge listens for public text-input editing notifications
and converts the active input into scroll-content coordinates. It compares
the input to the keyboard's converted end frame,
adds only the needed reveal distance, clamps the offset, and changes inset and
offset using the keyboard notification's animation duration and curve.

Apple already provides keyboard safe areas, dismissal modifiers and
UIKeyboardLayoutGuide. This package packages an explicit reveal policy for
SwiftUI forms; it does not claim Apple lacks keyboard support or that keyboard
notifications are the only solution.

The original `KeyboardManagedScrollView` and `.keyboardManagedFocus(_:)` APIs
remain available for existing integrations and explicit custom focus bounds.
They are not required by the simple modifier API. Container backgrounds are
transparent; your app owns its background and the system owns keyboard appearance.

- [Apple: Keep up with the keyboard](https://developer.apple.com/videos/play/wwdc2023/10281/)
- [Apple: Keyboard layout guide](https://developer.apple.com/documentation/uikit/adjusting-your-layout-with-keyboard-layout-guide)
- [Apple: SwiftUI keyboard dismissal](https://developer.apple.com/documentation/swiftui/view/scrolldismisseskeyboard(_:))

## Sample app

Open `Examples/KeyboardDemo`, run `xcodegen generate`, and open
`KeyboardDemo.xcodeproj`. Choose an iPhone simulator and run **KeyboardDemo**.
The sample links the local package, so changing the library updates the demo.

The sample covers several fields, a multiline editor, enough lower content to
scroll, and all three dismissal modes. The recording above demonstrates the
multiline editor and on-drag dismissal on a dedicated iPhone Simulator.

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
