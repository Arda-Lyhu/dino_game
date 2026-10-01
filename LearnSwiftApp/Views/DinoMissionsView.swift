import SwiftUI

struct DinoMissionsView: View {
    @ObservedObject var gameManager = DinoGameManager.shared
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    // Header Banner
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("QUEST EXPEDITIONS")
                                .font(.system(size: 10, weight: .heavy, design: .monospaced))
                                .foregroundStyle(AppTheme.coral)
                            Text("Daily Missions")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Mission Cards
                    ForEach(gameManager.missions) { mission in
                        MissionCard(mission: mission) {
                            gameManager.claimMissionReward(missionId: mission.id)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Lifetime Milestones Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Prehistoric Milestones")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        MilestoneCard(
                            title: "Century Runner",
                            subtitle: "Reach 100 points in a single run",
                            isUnlocked: gameManager.highScore >= 100,
                            icon: "rosette",
                            accentColor: AppTheme.neonGreen
                        )
                        
                        MilestoneCard(
                            title: "Jurassic Legend",
                            subtitle: "Reach 500 points in a single run",
                            isUnlocked: gameManager.highScore >= 500,
                            icon: "crown.fill",
                            accentColor: AppTheme.gold
                        )
                        
                        MilestoneCard(
                            title: "Obstacle Smasher",
                            subtitle: "Clear 50 total obstacles",
                            isUnlocked: gameManager.totalObstaclesCleared >= 50,
                            icon: "shield.slash.fill",
                            accentColor: AppTheme.purple
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 36)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

// MARK: - Mission Card
struct MissionCard: View {
    let mission: GameMission
    let onClaim: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(mission.title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Progress: \(min(mission.progress, mission.goal)) / \(mission.goal)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.55))
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "circle.fill")
                        .foregroundStyle(AppTheme.gold)
                        .font(.caption2)
                    Text("+\(mission.rewardCoins)")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .glassCard(cornerRadius: 12, strokeColor: AppTheme.gold.opacity(0.3))
            }
            
            // Neon Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.08))
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(mission.isCompleted ? AnyShapeStyle(AppTheme.neonGreen) : AnyShapeStyle(AppTheme.coral))
                        .frame(width: min(geo.size.width, geo.size.width * CGFloat(mission.progressRatio)))
                        .shadow(color: (mission.isCompleted ? AppTheme.neonGreen : AppTheme.coral).opacity(0.5), radius: 4)
                }
            }
            .frame(height: 7)
            
            // Claim button or status
            if mission.isClaimed {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("CLAIMED")
                }
                .font(.system(size: 10, weight: .heavy, design: .monospaced))
                .foregroundStyle(.white.opacity(0.4))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            } else if mission.isCompleted {
                Button(action: onClaim) {
                    Text("CLAIM REWARD")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppTheme.playButtonGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: AppTheme.neonGreen.opacity(0.4), radius: 6)
                }
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 18, strokeColor: mission.isCompleted && !mission.isClaimed ? AppTheme.neonGreen.opacity(0.4) : Color.white.opacity(0.08))
    }
}

// MARK: - Milestone Card
struct MilestoneCard: View {
    let title: String
    let subtitle: String
    let isUnlocked: Bool
    let icon: String
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(isUnlocked ? accentColor : .white.opacity(0.3))
                .frame(width: 42, height: 42)
                .background((isUnlocked ? accentColor : Color.white).opacity(0.12))
                .clipShape(Circle())
                .shadow(color: isUnlocked ? accentColor.opacity(0.4) : .clear, radius: 6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(isUnlocked ? .white : .white.opacity(0.4))
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.5))
            }
            
            Spacer()
            
            if isUnlocked {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(accentColor)
                    .font(.system(size: 18))
            } else {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.white.opacity(0.25))
                    .font(.system(size: 14))
            }
        }
        .padding(14)
        .glassCard(cornerRadius: 16, strokeColor: isUnlocked ? accentColor.opacity(0.3) : Color.white.opacity(0.06))
    }
}

#Preview {
    NavigationStack {
        DinoMissionsView()
    }
}
