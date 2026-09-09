import Foundation
import Testing
@testable import SwiftUIKeyboardManager

@Test func visibleFieldDoesNotMove() {
    #expect(KeyboardGeometry.revealOffset(current: 200, field: CGRect(x: 0, y: 240, width: 200, height: 44), visibleBottom: 600, spacing: 16) == 200)
}

@Test func revealsOnlyTheOccludedDistanceFromCurrentScrollPosition() {
    #expect(KeyboardGeometry.revealOffset(current: 200, field: CGRect(x: 0, y: 650, width: 200, height: 44), visibleBottom: 600, spacing: 16) == 294)
}

@Test func tallEditorKeepsItsTopVisible() {
    #expect(KeyboardGeometry.revealOffset(current: 200, field: CGRect(x: 0, y: 250, width: 200, height: 600), visibleBottom: 600, spacing: 16) == 234)
}
