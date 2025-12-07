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
    static let neutral400 = Color(red: 160/255, green: 174/255, blue: 188/255)
    static let neutral700 = Color(red: 74/255, green: 85/255, blue: 104/255)
    static let neutral900 = Color(red: 26/255, green: 32/255, blue: 44/255)
    
    static let success500 = Color(red: 40/255, green: 167/255, blue: 69/255)
    static let error500 = Color(red: 220/255, green: 53/255, blue: 69/255)
}


struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct FloatingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .offset(y: configuration.isPressed ? 2 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}


struct CardShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .primaryBlue.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct PressableModifier: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
    }
}


struct CustomRoundedRectangle: Shape {
    var topLeft: CGFloat = 0
    var topRight: CGFloat = 0
    var bottomRight: CGFloat = 0
    var bottomLeft: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let topLeftRect = CGRect(x: rect.minX, y: rect.minY, width: topLeft, height: topLeft)
        let topRightRect = CGRect(x: rect.maxX - topRight, y: rect.minY, width: topRight, height: topRight)
        let bottomRightRect = CGRect(x: rect.maxX - bottomRight, y: rect.maxY - bottomRight, width: bottomRight, height: bottomRight)
        let bottomLeftRect = CGRect(x: rect.minX, y: rect.maxY - bottomLeft, width: bottomLeft, height: bottomLeft)
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        
        path.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + topRight), control: CGPoint(x: rect.maxX, y: rect.minY))
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
        
        path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - bottomLeft), control: CGPoint(x: rect.minX, y: rect.maxY))
        
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
        path.addQuadCurve(to: CGPoint(x: rect.minX + topLeft, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
        
        path.closeSubpath()
        return path
    }
}


extension Animation {
    static func buttonPress() -> Animation {
        .spring(response: 0.3, dampingFraction: 0.6)
    }
    
    static func cardBounce() -> Animation {
        .spring(response: 0.4, dampingFraction: 0.8)
    }
    
    static func slideIn() -> Animation {
        .easeInOut(duration: 0.3)
    }
    
    static func fadeIn() -> Animation {
        .easeInOut(duration: 0.5)
    }
}


extension View {
    func cardShadow() -> some View {
        self.modifier(CardShadowModifier())
    }
    
    func pressable() -> some View {
        self.modifier(PressableModifier())
    }
    
    func roundedCorners(_ radius: CGFloat) -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: radius))
    }
    
    func customRoundedCorners(topLeft: CGFloat, topRight: CGFloat, bottomRight: CGFloat, bottomLeft: CGFloat) -> some View {
        self.clipShape(CustomRoundedRectangle(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft))
    }
}


extension Text {
    func gradientForeground(from: Color, to: Color) -> some View {
        self.foregroundStyle(
            LinearGradient(
                colors: [from, to],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}


extension Image {
    func customIconStyle(size: CGFloat = 24, color: Color = .primaryBlue) -> some View {
        self
            .font(.system(size: size))
            .foregroundColor(color)
    }
}


extension Rectangle {
    func gradientFill(from: Color, to: Color) -> some View {
        self.fill(
            LinearGradient(
                colors: [from, to],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}


extension HStack {
    func evenlySpaced() -> some View {
        self.frame(maxWidth: .infinity)
    }
}


extension VStack {
    func centerAll() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}


extension GeometryProxy {
    var center: CGPoint {
        CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    var topCenter: CGPoint {
        CGPoint(x: size.width / 2, y: 0)
    }
    
    var bottomCenter: CGPoint {
        CGPoint(x: size.width / 2, y: size.height)
    }
    
    var leftCenter: CGPoint {
        CGPoint(x: 0, y: size.height / 2)
    }
    
    var rightCenter: CGPoint {
        CGPoint(x: size.width, y: size.height / 2)
    }
}


extension CGFloat {
    static let spacingXS: CGFloat = 8
    static let spacingSM: CGFloat = 12
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 48
    
    static let cornerRadiusSM: CGFloat = 8
    static let cornerRadiusMD: CGFloat = 12
    static let cornerRadiusLG: CGFloat = 16
    static let cornerRadiusXL: CGFloat = 20
    static let cornerRadiusXXL: CGFloat = 24
    
    static let cardShadow: CGFloat = 8
    static let buttonShadow: CGFloat = 6
}


struct UIConstants {
    static let cardPadding: CGFloat = 20
    static let buttonHeight: CGFloat = 50
    static let iconSize: CGFloat = 24
    static let avatarSize: CGFloat = 80
    static let gameTileSize: CGFloat = 40
    static let progressBarHeight: CGFloat = 8
    
    static let animationDuration: Double = 0.3
    static let springResponse: Double = 0.4
    static let springDamping: Double = 0.8
}


struct ColorPalette {
    static let primary = Color.primaryBlue
    static let secondary = Color.accentGold
    static let background = Color.neutral50
    static let surface = Color.neutral100
    static let textPrimary = Color.neutral900
    static let textSecondary = Color.neutral700
    static let success = Color.success500
    static let error = Color.error500
    static let border = Color.neutral200
    
    static let gradients: [(Color, Color)] = [
        (primaryBlue, accentGold),
        (primaryBlueLight, primaryBlue),
        (accentGold, accentGold.opacity(0.8)),
        (success500.opacity(0.1), primaryBlue.opacity(0.1))
    ]
}


struct FontSizes {
    static let caption: CGFloat = 12
    static let body: CGFloat = 14
    static let callout: CGFloat = 15
    static let subheadline: CGFloat = 16
    static let footnote: CGFloat = 13
    static let headline: CGFloat = 17
    static let title3: CGFloat = 20
    static let title2: CGFloat = 22
    static let title1: CGFloat = 28
    static let largeTitle: CGFloat = 34
}