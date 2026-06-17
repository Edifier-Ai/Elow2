import SwiftUI

enum ClayTheme {
    static let background = Color.white
    static let surface = Color(red: 0.97, green: 0.97, blue: 0.94)
    static let raised = Color(red: 0.99, green: 0.99, blue: 0.97)
    static let text = Color(red: 0.13, green: 0.13, blue: 0.12)
    static let secondaryText = Color(red: 0.45, green: 0.45, blue: 0.40)
    static let hairline = Color(red: 0.88, green: 0.88, blue: 0.84)
    static let selected = Color(red: 0.16, green: 0.16, blue: 0.14)
    static let accentSage = Color(red: 0.50, green: 0.63, blue: 0.55)
    static let accentCoffee = Color(red: 0.54, green: 0.35, blue: 0.24)
    static let paper = Color(red: 0.99, green: 0.98, blue: 0.94)

    static let cardRadius: CGFloat = 24
    static let controlRadius: CGFloat = 18

    static func raisedShadow() -> some ViewModifier {
        ClayRaisedShadow()
    }
}

private struct ClayRaisedShadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.black.opacity(0.08), radius: 18, x: 10, y: 14)
            .shadow(color: Color.white.opacity(0.95), radius: 8, x: -4, y: -5)
    }
}
