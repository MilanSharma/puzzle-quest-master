
import SwiftUI

extension Color {
    static let primaryBlue = Color(red: 0.0, green: 0.5, blue: 1.0)
    static let primaryBlueDark = Color(red: 0.0, green: 0.4, blue: 0.8)
    static let primaryBlueLight = Color(red: 0.8, green: 0.9, blue: 1.0)
    static let accentGold = Color(red: 1.0, green: 0.8, blue: 0.0)
    static let accentGoldDark = Color(red: 0.8, green: 0.6, blue: 0.0)
    static let neutral50 = Color(white: 0.98)
    static let neutral100 = Color(white: 0.95)
    static let neutral200 = Color(white: 0.90)
    static let neutral300 = Color(white: 0.80)
    static let neutral400 = Color(white: 0.60)
    static let neutral700 = Color(white: 0.30)
    static let neutral900 = Color(white: 0.10)
    static let success500 = Color.green
    static let error500 = Color.red
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View { configuration.label.scaleEffect(configuration.isPressed ? 0.96 : 1.0) }
}
struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View { configuration.label.scaleEffect(configuration.isPressed ? 0.92 : 1.0) }
}
struct FloatingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View { configuration.label }
}

struct CardShadowModifier: ViewModifier {
    func body(content: Content) -> some View { content.shadow(radius: 4) }
}
struct PressableModifier: ViewModifier {
    func body(content: Content) -> some View { content }
}

extension View {
    func cardShadow() -> some View { self.modifier(CardShadowModifier()) }
    func roundedCorners(_ radius: CGFloat) -> some View { self.clipShape(RoundedRectangle(cornerRadius: radius)) }
    func customRoundedCorners(topLeft: CGFloat, topRight: CGFloat, bottomRight: CGFloat, bottomLeft: CGFloat) -> some View { self }
}
