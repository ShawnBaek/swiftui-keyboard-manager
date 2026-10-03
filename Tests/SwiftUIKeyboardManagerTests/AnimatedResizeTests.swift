#if os(iOS)
import SwiftUI
import Testing
import UIKit
@testable import SwiftUIKeyboardManager

@MainActor @Observable
private final class RowModel {
    var showsRow = false
}

/// A UIKit view placed by SwiftUI, so a test can read where SwiftUI draws a row.
private final class ProbeView: UIView {
    /// This view's top in window coordinates, as drawn on screen (presentation layers).
    var drawnTop: CGFloat {
        var y: CGFloat = 0
        var current: CALayer? = layer
        while let model = current {
            y += (model.presentation() ?? model).frame.minY
            if let superlayer = model.superlayer {
                y -= (superlayer.presentation() ?? superlayer).bounds.minY
            }
            current = model.superlayer
        }
        return y
    }
}

private struct Probe: UIViewRepresentable {
    let view: ProbeView
    func makeUIView(context: Context) -> ProbeView { view }
    func updateUIView(_ uiView: ProbeView, context: Context) {}
}

private struct GrowingContent: View {
    let model: RowModel
    let top: ProbeView
    let bottom: ProbeView

    var body: some View {
        VStack(spacing: 0) {
            Color.red.frame(height: 100).background(Probe(view: top))
            if model.showsRow {
                Color.blue.frame(height: 16).transition(.opacity)
            }
            Color.green.frame(height: 100).background(Probe(view: bottom))
        }
    }
}

private struct Samples {
    var top: [CGFloat] = []
    var bottom: [CGFloat] = []
    var contentHeight: CGFloat = 0
}

/// Inserts a 16 pt row between two probed rows with animation and samples where both rows are
/// drawn on each frame of the animation.
@MainActor
private func insertRow(duration: Double) async throws -> Samples {
    let model = RowModel()
    let top = ProbeView()
    let bottom = ProbeView()
    let controller = KeyboardScrollController(
        content: GrowingContent(model: model, top: top, bottom: bottom),
        mode: .never,
        spacing: 16,
        onUserScroll: {}
    )
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 600))
    window.rootViewController = controller
    window.makeKeyAndVisible()
    controller.view.layoutIfNeeded()
    try await Task.sleep(for: .milliseconds(100))
    var samples = Samples()
    samples.top.append(top.drawnTop)
    samples.bottom.append(bottom.drawnTop)
    withAnimation(.easeInOut(duration: duration)) {
        model.showsRow = true
    }
    for _ in 0..<(Int(duration * 60) + 6) {
        try await Task.sleep(for: .milliseconds(16))
        samples.top.append(top.drawnTop)
        samples.bottom.append(bottom.drawnTop)
    }
    controller.view.layoutIfNeeded()
    samples.contentHeight = controller.host.view.frame.height
    window.isHidden = true
    return samples
}

@Test func rowAboveAnInsertedRowStaysStill() async throws {
    let samples = try await insertRow(duration: 0.3)
    let before = samples.top[0]
    let largestShift = samples.top.map { abs($0 - before) }.max() ?? 0
    #expect(largestShift < 0.5, "top row moved by up to \(largestShift) pt from \(before): \(samples.top)")
}

@Test func rowBelowAnInsertedRowSlidesDownWithoutJumping() async throws {
    let samples = try await insertRow(duration: 0.3)
    let path = samples.bottom
    #expect(path.first == 100)
    #expect(path.last == 116)
    // Moves only downward, and never more than a third of the row in one frame.
    let steps = zip(path, path.dropFirst()).map { $1 - $0 }
    #expect(steps.allSatisfy { $0 > -0.5 && $0 < 6 }, "bottom row path: \(path)")
}

@Test func hostKeepsTheContentHeight() async throws {
    let samples = try await insertRow(duration: 0.3)
    #expect(samples.contentHeight == 216)
}
#endif
