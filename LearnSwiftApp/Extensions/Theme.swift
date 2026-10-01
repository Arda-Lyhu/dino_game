import SwiftUI

/// Centralized Design System Palette, Gradients, and Glassmorphism Styles.
enum AppTheme {
    // MARK: - Dark Background Palette
    static let backgroundPrimary = Color(hex: "#0A0D14")
    static let backgroundSecondary = Color(hex: "#121722")
    static let backgroundTertiary = Color(hex: "#1A2232")
    
    static let cardBackground = Color(hex: "#151B28").opacity(0.85)
    static let cardBorder = Color.white.opacity(0.1)
    static let cardGlowBorder = LinearGradient(
        colors: [Color.white.opacity(0.25), Color.white.opacity(0.05)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Vibrant Accents
    static let neonGreen = Color(hex: "#00F59B")
    static let neonGreenDark = Color(hex: "#00BA71")
    static let gold = Color(hex: "#FFD200")
    static let goldDark = Color(hex: "#FFA000")
    static let cyan = Color(hex: "#00E5FF")
    static let purple = Color(hex: "#A855F7")
    static let coral = Color(hex: "#FF4757")
    
    // MARK: - Gradients
    static let playButtonGradient = LinearGradient(
        colors: [Color(hex: "#00F59B"), Color(hex: "#00C48C")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let goldGradient = LinearGradient(
        colors: [Color(hex: "#FFE259"), Color(hex: "#FFA751")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cyanGradient = LinearGradient(
        colors: [Color(hex: "#00E5FF"), Color(hex: "#0072FF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [Color(hex: "#0B0E17"), Color(hex: "#080A10"), Color(hex: "#05060A")],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - View Modifiers for Glassmorphism
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var strokeColor: Color = Color.white.opacity(0.12)
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [strokeColor, strokeColor.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20, strokeColor: Color = Color.white.opacity(0.12)) -> some View {
        self.modifier(GlassCardModifier(cornerRadius: cornerRadius, strokeColor: strokeColor))
    }
}
