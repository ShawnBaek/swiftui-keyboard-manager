# Demo evidence

## Verified on iPhone Simulator

Source: `7162731f3204f05081d382d3f82e00fb0cc669fb`.
Device: iPhone 17 Pro, iOS 27 (24A5423a), portrait, light appearance,
English. Built with Xcode 27 (27A5252f).

- The lower Location TextField and Bio TextEditor each settled 16 points above
  the software keyboard, matching the configured keyboard spacing.
- Tapping the software keyboard entered text into the TextEditor.
- `.onDrag`: dragging the outer scroll view dismissed the keyboard.
- `.never`: dragging preserved the keyboard and input focus.
- `.interactive`: a downward drag dismissed the keyboard.
- No opaque white strip was visible between the content and keyboard.
- Hosted input controls were present in the accessibility hierarchy.

These are observed settled geometry and gesture checks, not frame-by-frame
proof of animation synchronization. Floating keyboards, interactive cancellation,
and other device configurations remain unverified.

## Recording status

An actual screen recording and inline README video are still pending. The
simulator app-launch connection stalled while preparing a clean recording after
the checks above. No screenshot sequence or simulated animation is presented as
a recording. The sample uses synthetic text only.

The source build passed, and GitHub Actions run
[34372993165](https://github.com/ShawnBaek/swiftui-keyboard-manager/actions/runs/34372993165)
passed the three package tests and the iOS library build.
