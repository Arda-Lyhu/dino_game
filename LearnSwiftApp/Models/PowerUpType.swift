import SwiftUI

/// Available power-up types with metadata, upgrade math, and UI styling.
enum PowerUpType: String, CaseIterable, Identifiable, Codable {
    case magnet = "Coin Magnet"
    case shield = "Energy Shield"
    case boost = "Jump Booster"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .magnet:
            return "Attracts nearby gold coins automatically within a magnetic field."
        case .shield:
            return "Absorbs one collision hazard with an energy forcefield."
        case .boost:
            return "Provides enhanced jump height and extended air glide time."
        }
    }
    
    var iconName: String {
        switch self {
        case .magnet:
            return "arrow.down.to.line.circle.fill"
        case .shield:
            return "shield.lefthalf.filled"
        case .boost:
            return "wind"
        }
    }
    
    var themeColor: Color {
        switch self {
        case .magnet:
            return .orange
        case .shield:
            return .cyan
        case .boost:
            return .purple
        }
    }
    
    static let maxLevel: Int = 5
    
    /// Calculate the cost to upgrade from the given level.
    static func upgradeCost(for currentLevel: Int) -> Int {
        return currentLevel * 100
    }
}
