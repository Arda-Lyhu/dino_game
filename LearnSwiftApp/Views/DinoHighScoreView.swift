import SwiftUI

struct DinoHighScoreView: View {
    @ObservedObject var gameManager = DinoGameManager.shared
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Giant High Score Hero Trophy Card
                    VStack(spacing: 12) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 58))
                            .foregroundStyle(AppTheme.goldGradient)
                            .shadow(color: AppTheme.gold.opacity(0.6), radius: 16, y: 6)
                        
                        Text("ALL-TIME RUN RECORD")
                            .font(.system(size: 10, weight: .heavy, design: .monospaced))
                            .foregroundStyle(AppTheme.gold)
                        
                        Text("\(gameManager.highScore)")
                            .font(.system(size: 56, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.5), radius: 6)
                        
                        Text("Points scored in a single 3D run")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(26)
                    .glassCard(cornerRadius: 24, strokeColor: AppTheme.gold.opacity(0.4))
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Career Statistics Grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Career Statistics")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            StatCard(icon: "figure.run", title: "Total Runs", value: "\(gameManager.totalRuns)", accentColor: AppTheme.cyan)
                            StatCard(icon: "shield.checkered", title: "Obstacles Cleared", value: "\(gameManager.totalObstaclesCleared)", accentColor: AppTheme.neonGreen)
                            StatCard(icon: "circle.fill", title: "Gold Collected", value: "\(gameManager.coins)", accentColor: AppTheme.gold)
                            StatCard(icon: "sparkles", title: "Skins Owned", value: "\(gameManager.unlockedSkinIds.count) / \(gameManager.availableSkins.count)", accentColor: AppTheme.purple)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Local Hall of Fame / Ranks
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Rank Progression")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(.horizontal)
                        
                        RankRow(rank: "1", title: "Apex Predator", req: "500+ PTS", achieved: gameManager.highScore >= 500, color: AppTheme.purple)
                        RankRow(rank: "2", title: "Velociraptor", req: "250+ PTS", achieved: gameManager.highScore >= 250, color: AppTheme.cyan)
                        RankRow(rank: "3", title: "Desert Sprinter", req: "100+ PTS", achieved: gameManager.highScore >= 100, color: AppTheme.neonGreen)
                        RankRow(rank: "4", title: "Hatchling", req: "0+ PTS", achieved: true, color: AppTheme.coral)
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

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(accentColor)
                .frame(width: 32, height: 32)
                .background(accentColor.opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text(title)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.55))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .glassCard(cornerRadius: 18, strokeColor: accentColor.opacity(0.2))
    }
}

struct RankRow: View {
    let rank: String
    let title: String
    let req: String
    let achieved: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 14) {
            Text(rank)
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundStyle(achieved ? .black : .white.opacity(0.4))
                .frame(width: 32, height: 32)
                .background(achieved ? color : Color.white.opacity(0.08))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(achieved ? .white : .white.opacity(0.4))
                Text(req)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.45))
            }
            
            Spacer()
            
            if achieved {
                Text("UNLOCKED")
                    .font(.system(size: 9, weight: .heavy, design: .monospaced))
                    .foregroundStyle(color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.15))
                    .clipShape(Capsule())
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.25))
            }
        }
        .padding(12)
        .glassCard(cornerRadius: 16, strokeColor: achieved ? color.opacity(0.25) : Color.white.opacity(0.06))
    }
}

#Preview {
    NavigationStack {
        DinoHighScoreView()
    }
}
