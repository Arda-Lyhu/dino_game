import Foundation

/// Centralized, type-safe keys for UserDefaults and @AppStorage persistence.
enum StorageKey {
    // Currencies & Scores
    static let coins = "dino_coins"
    static let gems = "dino_gems"
    static let highScore = "dino_highScore"
    
    // Lifetime Statistics
    static let totalRuns = "dino_totalRuns"
    static let totalObstaclesCleared = "dino_totalObstaclesCleared"
    static let totalDistance = "dino_totalDistance"
    
    // Settings
    static let soundEnabled = "dino_soundEnabled"
    static let hapticsEnabled = "dino_hapticsEnabled"
    static let highGraphics = "dino_highGraphics"
    
    // Customization & Upgrades
    static let equippedSkinId = "dino_equippedSkinId"
    static let unlockedSkins = "dino_unlockedSkins"
    static let magnetLevel = "dino_magnetLevel"
    static let shieldLevel = "dino_shieldLevel"
    static let boostLevel = "dino_boostLevel"
}
