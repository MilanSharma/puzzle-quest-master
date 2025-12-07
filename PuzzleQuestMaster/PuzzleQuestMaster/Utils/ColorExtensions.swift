import SwiftUI

extension Color {
    static let primaryBlue = Color(red: 0/255, green: 123/255, blue: 255/255)
    static let primaryBlueDark = Color(red: 0/255, green: 86/255, blue: 179/255)
    static let primaryBlueLight = Color(red: 204/255, green: 229/255, blue: 255/255)
    
    static let accentGold = Color(red: 255/255, green: 193/255, blue: 7/255)
    static let accentGoldDark = Color(red: 211/255, green: 158/255, blue: 0/255)
    
    static let neutral50 = Color(red: 247/255, green: 250/255, blue: 252/255)
    static let neutral100 = Color(red: 255/255, green: 255/255, blue: 255/255)
    static let neutral200 = Color(red: 226/255, green: 232/255, blue: 240/255)
    // ADDED MISSING COLOR
    static let neutral300 = Color(red: 203/255, green: 213/255, blue: 224/255)
    static let neutral400 = Color(red: 160/255, green: 174/255, blue: 188/255)
    static let neutral700 = Color(red: 74/255, green: 85/255, blue: 104/255)
    static let neutral900 = Color(red: 26/255, green: 32/255, blue: 44/255)
    
    static let success500 = Color(red: 40/255, green: 167/255, blue: 69/255)
    static let error500 = Color(red: 220/255, green: 53/255, blue: 69/255)
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.scaleEffect(configuration.isPressed ? 0.96 : 1.0)
    }
}
struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.scaleEffect(configuration.isPressed ? 0.92 : 1.0)
    }
}

// View Modifiers
struct CardShadowModifier: ViewModifier {
    func body(content: Content) -> some View { content.shadow(color: .primaryBlue.opacity(0.1), radius: 8, x: 0, y: 4) }
}

extension View {
    func cardShadow() -> some View { self.modifier(CardShadowModifier()) }
    func roundedCorners(_ radius: CGFloat) -> some View { self.clipShape(RoundedRectangle(cornerRadius: radius)) }
}
