import SwiftUI
import Combine

/// Centralized state manager for user progress, economy, settings, and gameplay sessions.
@MainActor
final class DinoGameManager: ObservableObject {
    static let shared = DinoGameManager()
    
    // MARK: - Persistent Economy & Stats
    @AppStorage(StorageKey.coins) var coins: Int = 2500
    @AppStorage(StorageKey.gems) var gems: Int = 50
    @AppStorage(StorageKey.highScore) var highScore: Int = 0
    @AppStorage(StorageKey.totalRuns) var totalRuns: Int = 0
    @AppStorage(StorageKey.totalObstaclesCleared) var totalObstaclesCleared: Int = 0
    
    // MARK: - User Settings
    @AppStorage(StorageKey.soundEnabled) var soundEnabled: Bool = true
    @AppStorage(StorageKey.hapticsEnabled) var hapticsEnabled: Bool = true {
        didSet {
            HapticsManager.shared.isEnabled = hapticsEnabled
        }
    }
    @AppStorage(StorageKey.highGraphics) var highGraphics: Bool = true
    
    // MARK: - Character Customization
    @AppStorage(StorageKey.equippedSkinId) var equippedSkinId: String = "classic"
    @AppStorage(StorageKey.unlockedSkins) private var unlockedSkinsRaw: String = "classic"
    
    // MARK: - Upgrades Progression
    @AppStorage(StorageKey.magnetLevel) var magnetLevel: Int = 1
    @AppStorage(StorageKey.shieldLevel) var shieldLevel: Int = 1
    @AppStorage(StorageKey.boostLevel) var boostLevel: Int = 1
    
    // MARK: - Active Daily Missions
    @Published var missions: [GameMission] = GameMission.defaultSet
    
    // MARK: - Skins Accessors
    var availableSkins: [DinoSkin] {
        DinoSkin.catalog
    }
    
    var equippedSkin: DinoSkin {
        availableSkins.first { $0.id == equippedSkinId } ?? availableSkins[0]
    }
    
    var unlockedSkinIds: Set<String> {
        Set(unlockedSkinsRaw.components(separatedBy: ",").filter { !$0.isEmpty })
    }
    
    private init() {
        HapticsManager.shared.isEnabled = hapticsEnabled
    }
    
    // MARK: - Skin Operations
    func isSkinUnlocked(_ skin: DinoSkin) -> Bool {
        skin.price == 0 || unlockedSkinIds.contains(skin.id)
    }
    
    @discardableResult
    func unlockSkin(_ skin: DinoSkin) -> Bool {
        guard coins >= skin.price, !isSkinUnlocked(skin) else { return false }
        coins -= skin.price
        
        var current = unlockedSkinIds
        current.insert(skin.id)
        unlockedSkinsRaw = current.joined(separator: ",")
        
        equippedSkinId = skin.id
        HapticsManager.shared.notification(.success)
        return true
    }
    
    func equipSkin(_ skin: DinoSkin) {
        guard isSkinUnlocked(skin) else { return }
        equippedSkinId = skin.id
        HapticsManager.shared.selection()
    }
    
    // MARK: - Power-Up Operations
    func currentLevel(for powerUp: PowerUpType) -> Int {
        switch powerUp {
        case .magnet: return magnetLevel
        case .shield: return shieldLevel
        case .boost: return boostLevel
        }
    }
    
    func upgradeCost(for powerUp: PowerUpType) -> Int {
        PowerUpType.upgradeCost(for: currentLevel(for: powerUp))
    }
    
    @discardableResult
    func upgradePowerUp(_ powerUp: PowerUpType) -> Bool {
        let level = currentLevel(for: powerUp)
        guard level < PowerUpType.maxLevel else { return false }
        
        let cost = upgradeCost(for: powerUp)
        guard coins >= cost else { return false }
        
        coins -= cost
        switch powerUp {
        case .magnet: magnetLevel += 1
        case .shield: shieldLevel += 1
        case .boost: boostLevel += 1
        }
        
        HapticsManager.shared.notification(.success)
        return true
    }
    
    // MARK: - Session & Stats Recording
    func recordRun(score: Int, coinsCollected: Int, obstaclesCleared: Int) {
        totalRuns += 1
        coins += coinsCollected
        totalObstaclesCleared += obstaclesCleared
        
        if score > highScore {
            highScore = score
        }
        
        updateMissionsProgress(score: score, coinsCollected: coinsCollected, obstaclesCleared: obstaclesCleared)
    }
    
    private func updateMissionsProgress(score: Int, coinsCollected: Int, obstaclesCleared: Int) {
        if let idx = missions.firstIndex(where: { $0.id == "mission_score" }) {
            missions[idx].progress = max(missions[idx].progress, score)
        }
        if let idx = missions.firstIndex(where: { $0.id == "mission_coins" }) {
            missions[idx].progress += coinsCollected
        }
        if let idx = missions.firstIndex(where: { $0.id == "mission_obstacles" }) {
            missions[idx].progress += obstaclesCleared
        }
    }
    
    // MARK: - Mission Rewards
    func claimMissionReward(missionId: String) {
        guard let idx = missions.firstIndex(where: { $0.id == missionId }),
              missions[idx].isCompleted,
              !missions[idx].isClaimed else { return }
        
        missions[idx].isClaimed = true
        coins += missions[idx].rewardCoins
        HapticsManager.shared.notification(.success)
    }
    
    // MARK: - Free Coins Air-Drop
    func claimFreeCoinsAirDrop(amount: Int = 1000) {
        coins += amount
        HapticsManager.shared.notification(.success)
        AudioService.shared.playCoinSound()
    }
    
    // MARK: - Data Reset
    func resetAllData() {
        highScore = 0
        totalRuns = 0
        totalObstaclesCleared = 0
        coins = 2500
        gems = 50
        magnetLevel = 1
        shieldLevel = 1
        boostLevel = 1
        unlockedSkinsRaw = "classic"
        equippedSkinId = "classic"
        missions = GameMission.defaultSet
        HapticsManager.shared.notification(.warning)
    }
}
