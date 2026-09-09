import SwiftUI

/// Controls how a user scroll gesture interacts with the software keyboard.
public enum SwipeToDismiss: String, CaseIterable, Sendable {
    /// Scrolling preserves keyboard focus.
    case never
    /// Dismiss as soon as a user starts dragging.
    case onDrag
    /// Use UIKit's interactive keyboard dismissal gesture.
    case interactive
}

/// A vertical scroll container that reveals a marked SwiftUI input above the keyboard.
///
/// Put non-scrolling content in this container, and mark each input with
/// `keyboardManagedFocus(_:)`. Do not wrap an existing Form, List or ScrollView.
@MainActor
public struct KeyboardManagedScrollView<Content: View>: View {
    private let swipeToDismiss: SwipeToDismiss
    private let keyboardSpacing: CGFloat
    private let onDismiss: () -> Void
    private let content: Content
    private let showsIndicators: Bool
    @Environment(\.self) private var environment

    public init(
        swipeToDismiss: SwipeToDismiss = .onDrag,
        keyboardSpacing: CGFloat = 16,
        showsIndicators: Bool = true,
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder content: () -> Content
    ) {
        self.swipeToDismiss = swipeToDismiss
        self.keyboardSpacing = keyboardSpacing.isFinite ? max(0, keyboardSpacing) : 16
        self.onDismiss = onDismiss
        self.content = content()
        self.showsIndicators = showsIndicators
    }

    public var body: some View {
        #if os(iOS)
        KeyboardTrackingScrollView(onUserScroll: onDismiss, mode: swipeToDismiss, spacing: keyboardSpacing, showsIndicators: showsIndicators) {
            content.environment(\.self, environment)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        #else
        ScrollView { content }
        #endif
    }
}

public extension ScrollView {
    /// Adds keyboard-synchronized scrolling with automatic input tracking.
    ///
    /// Call directly on a vertical `ScrollView`, before other view modifiers.
    /// The adapter uses its public content in an owned scroll container, rather
    /// than inspecting SwiftUI's private scroll implementation. Use eager content
    /// such as `VStack`; native scroll-position APIs and lazy stacks aren't supported.
    /// Horizontal/mixed-axis views retain native scrolling and dismissal only.
    @MainActor @ViewBuilder
    func keyboardManager(
        dismiss: SwipeToDismiss = .onDrag,
        keyboardSpacing: CGFloat = 16
    ) -> some View {
        #if os(iOS)
        if axes == .vertical {
            KeyboardManagedScrollView(
                swipeToDismiss: dismiss,
                keyboardSpacing: keyboardSpacing,
                showsIndicators: showsIndicators
            ) { content }
        } else {
            self.scrollDismissesKeyboard(
                dismiss == .never ? .never : dismiss == .onDrag ? .immediately : .interactively
            )
        }
        #else
        self
        #endif
    }
}

public extension View {
    /// Marks the bounds to reveal when this input owns your FocusState.
    /// Supports TextField, SecureField, TextEditor, and custom SwiftUI input views.
    @MainActor
    func keyboardManagedFocus(_ isFocused: Bool) -> some View {
        #if os(iOS)
        background(KeyboardFocusMarker(isFocused: isFocused))
        #else
        self
        #endif
    }
}
