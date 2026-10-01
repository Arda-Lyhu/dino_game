import Foundation

/// Represents a daily task or quest available to the player.
struct GameMission: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let goal: Int
    var progress: Int
    let rewardCoins: Int
    var isClaimed: Bool
    
    var isCompleted: Bool {
        progress >= goal
    }
    
    var progressRatio: Double {
        guard goal > 0 else { return 0 }
        return min(1.0, Double(progress) / Double(goal))
    }
    
    // MARK: - Default Daily Missions Set
    static let defaultSet: [GameMission] = [
        GameMission(
            id: "mission_score",
            title: "Survive & Score 200 PTS",
            goal: 200,
            progress: 0,
            rewardCoins: 50,
            isClaimed: false
        ),
        GameMission(
            id: "mission_coins",
            title: "Collect 30 Gold Coins",
            goal: 30,
            progress: 0,
            rewardCoins: 75,
            isClaimed: false
        ),
        GameMission(
            id: "mission_obstacles",
            title: "Clear 15 Obstacles Safely",
            goal: 15,
            progress: 0,
            rewardCoins: 100,
            isClaimed: false
        )
    ]
}
