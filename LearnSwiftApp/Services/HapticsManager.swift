import UIKit

/// Dedicated service for tactile feedback and notifications.
@MainActor
final class HapticsManager {
    static let shared = HapticsManager()
    
    var isEnabled: Bool = true
    
    private init() {}
    
    /// Trigger an impact feedback pattern.
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Trigger a notification feedback pattern (success, warning, error).
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    /// Trigger a selection tick feedback.
    func selection() {
        guard isEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
