import Foundation

enum KeyboardGeometry {
    /// All values are in scroll-content coordinates, including the current offset.
    static func revealOffset(current: CGFloat, field: CGRect, visibleBottom: CGFloat, spacing: CGFloat) -> CGFloat {
        let hidden = max(0, field.maxY - visibleBottom)
        let roomAbove = max(0, field.minY - current - spacing)
        return current + min(hidden, roomAbove)
    }
}
