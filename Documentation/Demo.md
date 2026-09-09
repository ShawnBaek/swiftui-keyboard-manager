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

## Published recording

https://github.com/user-attachments/assets/93c56c58-d5f4-4981-a7fa-9710b8a44d15

Captured on a newly created, dedicated iPhone 17 Pro Simulator with iOS 27
(24A5423a), portrait, light appearance, English, and a fixed 09:41 status bar.
Only the KeyboardDemo sample was installed for this capture. The earlier
simulator's app-launch connection stalled; the fresh device completed its first
boot, installation, launch, and this interaction successfully. This does not
establish another app as the cause of the earlier stall.

The continuous sequence focuses the lower Bio TextEditor, enters synthetic
`H` using the software keyboard, and drags the outer scroll view to dismiss.
The final state preserves the entered text. Focused editor bottom: 530 points;
keyboard top: 546 points (16-point spacing).

### Artifact provenance

- Source snapshot: `158415878e2d770e240df9c696a4a09a867a1c53`;
  implementation unchanged from `7162731f3204f05081d382d3f82e00fb0cc669fb`.
- Xcode: 27 (27A5252f); unsigned Debug iOS Simulator build, arm64.
- Capture: Apple's `simctl io recordVideo`, H.264, 1206 × 2622 pixels, no audio.
- Raw duration: 43.488333 seconds.
- Trim: start 15 seconds, duration 28.488333 seconds requested;
  actual published duration 28.486667 seconds.
- Trim tool: Apple `avconvert`, `PresetPassthrough`; no re-encode, speed change,
  intermediate cuts, reordered actions, or fabricated frames.
- Raw SHA-256: `e558259ca63f8e40ad907a18168aa46196b85bee5244276e25347f8ebaf1c875`.
- Published SHA-256: `e257a5b250cb9c62665eda3a732bd0cf64932ade403f1272854638ab68c1d83a`.

The recording shows this specific interaction, not universal frame-perfect
synchronization across all supported OS versions or keyboard configurations.

The source build passed, and GitHub Actions run
[34372993165](https://github.com/ShawnBaek/swiftui-keyboard-manager/actions/runs/34372993165)
passed the three package tests and the iOS library build.
