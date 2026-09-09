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
    @Environment(\.self) private var environment

    public init(
        swipeToDismiss: SwipeToDismiss = .onDrag,
        keyboardSpacing: CGFloat = 16,
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder content: () -> Content
    ) {
        self.swipeToDismiss = swipeToDismiss
        self.keyboardSpacing = keyboardSpacing.isFinite ? max(0, keyboardSpacing) : 16
        self.onDismiss = onDismiss
        self.content = content()
    }

    public var body: some View {
        #if os(iOS)
        KeyboardTrackingScrollView(onUserScroll: onDismiss, mode: swipeToDismiss, spacing: keyboardSpacing) {
            content.environment(\.self, environment)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        #else
        ScrollView { content }
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
