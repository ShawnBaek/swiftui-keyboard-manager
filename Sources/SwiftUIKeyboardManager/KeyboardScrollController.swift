import SwiftUI
#if os(iOS)
import UIKit
#endif

#if os(iOS)
/// Owns the scroll view so keyboard insets and scrolling have one animation owner.
/// All visible content and editable controls remain SwiftUI.
struct KeyboardTrackingScrollView<Content: View>: UIViewControllerRepresentable {
    var onUserScroll: () -> Void
    var mode: SwipeToDismiss
    var spacing: CGFloat
    var showsIndicators: Bool
    @ViewBuilder var content: () -> Content

    func makeUIViewController(context: Context) -> KeyboardScrollController<Content> {
        KeyboardScrollController(content: content(), mode: mode, spacing: spacing, onUserScroll: onUserScroll)
    }

    func updateUIViewController(_ controller: KeyboardScrollController<Content>, context: Context) {
        controller.host.rootView = content()
        controller.onUserScroll = onUserScroll
        controller.mode = mode
        controller.spacing = spacing
        controller.updateDismissMode()
        controller.setShowsIndicators(showsIndicators)
    }
}

private final class KeyboardOwnedScrollView: UIScrollView {
    weak var focusedMarker: KeyboardMarkerView?
    var revealFocus: (() -> Void)?
}

struct KeyboardFocusMarker: UIViewRepresentable {
    let isFocused: Bool

    func makeUIView(context: Context) -> KeyboardMarkerView { KeyboardMarkerView() }
    func updateUIView(_ view: KeyboardMarkerView, context: Context) {
        view.tracksFocusedField = isFocused
        view.registerFocus()
    }
}

final class KeyboardMarkerView: UIView {
    var tracksFocusedField = false
    private weak var owner: KeyboardOwnedScrollView?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        registerFocus()
    }

    func registerFocus() {
        // Locate only our public, owned scroll container, never SwiftUI's private controls.
        var ancestor = superview
        while let view = ancestor {
            if let scroll = view as? KeyboardOwnedScrollView {
                owner = scroll
                break
            }
            ancestor = view.superview
        }
        if tracksFocusedField {
            owner?.focusedMarker = self
            owner?.revealFocus?()
        } else if owner?.focusedMarker === self {
            owner?.focusedMarker = nil
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? { nil }
}

final class KeyboardScrollController<Content: View>: UIViewController, UIScrollViewDelegate {
    let host: UIHostingController<Content>
    var onUserScroll: () -> Void
    var mode: SwipeToDismiss
    var spacing: CGFloat
    private let scroll = KeyboardOwnedScrollView()
    private var keyboardScreenFrame: CGRect = .null
    private var animationEnd: TimeInterval = 0
    private var animationOptions: UIView.AnimationOptions = []
    private weak var activeInput: UIView?

    init(content: Content, mode: SwipeToDismiss, spacing: CGFloat, onUserScroll: @escaping () -> Void) {
        host = UIHostingController(rootView: content)
        self.onUserScroll = onUserScroll
        self.mode = mode
        self.spacing = spacing
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is unavailable") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.isOpaque = false
        scroll.backgroundColor = .clear
        scroll.isOpaque = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        updateDismissMode()
        scroll.delegate = self
        scroll.contentInsetAdjustmentBehavior = .never
        scroll.alwaysBounceVertical = true
        view.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        addChild(host)
        // UIKit handles avoidance here; prevent a second SwiftUI keyboard inset.
        host.safeAreaRegions = []
        host.sizingOptions = .intrinsicContentSize
        host.view.backgroundColor = .clear
        host.view.isOpaque = false
        host.view.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            host.view.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)
        ])
        host.didMove(toParent: self)
        scroll.revealFocus = { [weak self] in self?.adjustForKeyboard() }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
        for name in [UITextField.textDidBeginEditingNotification, UITextView.textDidBeginEditingNotification] {
            NotificationCenter.default.addObserver(self, selector: #selector(inputBeganEditing(_:)), name: name, object: nil)
        }
        for name in [UITextField.textDidEndEditingNotification, UITextView.textDidEndEditingNotification] {
            NotificationCenter.default.addObserver(self, selector: #selector(inputEndedEditing(_:)), name: name, object: nil)
        }
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    func setShowsIndicators(_ value: Bool) {
        loadViewIfNeeded()
        scroll.showsVerticalScrollIndicator = value
    }

    @objc private func inputBeganEditing(_ notification: Notification) {
        guard let input = notification.object as? UIView,
              input.isDescendant(of: scroll), input.window === view.window else { return }
        // Public editing notifications provide the actual responder: no swizzling,
        // private class names, or application-wide first-responder search.
        activeInput = input
        adjustForKeyboard()
    }

    @objc private func inputEndedEditing(_ notification: Notification) {
        if let input = notification.object as? UIView, input === activeInput {
            activeInput = nil
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard mode == .onDrag else { return }
        // Only a user's drag clears focus; keyboard-driven offset changes do not.
        scroll.focusedMarker = nil
        onUserScroll()
        host.view.endEditing(true)
    }

    func updateDismissMode() {
        switch mode {
        case .never: scroll.keyboardDismissMode = .none
        case .onDrag: scroll.keyboardDismissMode = .onDrag
        case .interactive: scroll.keyboardDismissMode = .interactive
        }
    }

    @objc private func keyboardChanged(_ notification: Notification) {
        guard view.window != nil, let info = notification.userInfo,
              activeInput != nil || scroll.focusedMarker != nil || !keyboardScreenFrame.isNull else { return }
        if let screen = notification.object as? UIScreen,
           screen !== view.window?.screen { return }
        if notification.name == UIResponder.keyboardWillHideNotification, mode == .interactive {
            scroll.focusedMarker = nil
            onUserScroll()
        }
        keyboardScreenFrame = notification.name == UIResponder.keyboardWillHideNotification
            ? .null : (info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .null)
        let duration = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let curve = (info[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 0
        animationEnd = ProcessInfo.processInfo.systemUptime + duration
        animationOptions = [UIView.AnimationOptions(rawValue: curve << 16), .beginFromCurrentState, .allowUserInteraction]
        adjustForKeyboard()
    }

    private func adjustForKeyboard() {
        guard let window = view.window else { return }
        view.layoutIfNeeded()
        let keyboard: CGRect
        if keyboardScreenFrame.isNull {
            keyboard = .null
        } else {
            let keyboardInWindow = window.convert(keyboardScreenFrame, from: window.screen.coordinateSpace)
            keyboard = view.convert(keyboardInWindow, from: window)
        }
        let overlap = keyboardScreenFrame.isNull ? CGRect.null : view.bounds.intersection(keyboard)
        // Floating keyboards don't create a full-width bottom inset.
        let docked = !overlap.isNull && keyboard.maxY >= view.bounds.maxY - 1
        let bottomInset = docked ? overlap.height : 0
        var offset = scroll.contentOffset
        if let input = (scroll.focusedMarker as UIView?) ?? activeInput, !overlap.isNull {
            let field = input.convert(input.bounds, to: scroll)
            let fieldInView = input.convert(input.bounds, to: view)
            if docked || fieldInView.intersects(keyboard) {
                let visibleBottom = scroll.convert(CGPoint(x: 0, y: keyboard.minY), from: view).y - spacing
                offset.y = KeyboardGeometry.revealOffset(current: offset.y, field: field, visibleBottom: visibleBottom, spacing: spacing)
            }
        }
        let maximum = max(0, scroll.contentSize.height - scroll.bounds.height + bottomInset)
        offset.y = min(maximum, max(0, offset.y))
        let duration = max(0, animationEnd - ProcessInfo.processInfo.systemUptime)
        UIView.animate(withDuration: duration, delay: 0, options: animationOptions) {
            self.scroll.contentInset.bottom = bottomInset
            self.scroll.verticalScrollIndicatorInsets.bottom = bottomInset
            self.scroll.contentOffset = offset
        }
    }
}
#endif
