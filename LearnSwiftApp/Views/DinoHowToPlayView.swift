import SwiftUI

struct DinoHowToPlayView: View {
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header Banner
                    VStack(spacing: 8) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(AppTheme.neonGreen)
                            .shadow(color: AppTheme.neonGreen.opacity(0.5), radius: 10)
                        
                        Text("Runner Master Guide")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Text("Master the touch gestures to survive the prehistoric wasteland!")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .glassCard(cornerRadius: 22, strokeColor: AppTheme.neonGreen.opacity(0.3))
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Controls Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Action Controls")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(.horizontal)
                        
                        ControlCard(
                            icon: "hand.tap.fill",
                            title: "Tap Screen or Swipe Up",
                            description: "Jump over ground cacti and boulders. Tap the on-screen JUMP button anytime.",
                            color: AppTheme.neonGreen
                        )
                        
                        ControlCard(
                            icon: "arrow.down.to.line.compact",
                            title: "Swipe Down",
                            description: "Duck underneath high-flying Pterodactyls or fast-dive to the ground from mid-air.",
                            color: AppTheme.coral
                        )
                        
                        ControlCard(
                            icon: "pause.circle.fill",
                            title: "Top-Right Button",
                            description: "Pause the run to take a breather or adjust settings.",
                            color: AppTheme.cyan
                        )
                    }
                    .padding(.horizontal)
                    
                    // Obstacles Codex
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Hazard Encyclopedia")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(.horizontal)
                        
                        ObstacleRow(
                            title: "Desert Cactus & Clusters",
                            tag: "GROUND HAZARD",
                            tagColor: AppTheme.neonGreen,
                            description: "Jump with precise timing to clear the sharp spines safely."
                        )
                        
                        ObstacleRow(
                            title: "Flying Pterodactyl",
                            tag: "AERIAL HAZARD",
                            tagColor: AppTheme.coral,
                            description: "Flies at various altitudes. Duck underneath if it flies high!"
                        )
                        
                        ObstacleRow(
                            title: "Ancient Stone Obelisk",
                            tag: "HEAVY HAZARD",
                            tagColor: AppTheme.gold,
                            description: "Tall solid rock formation requiring maximum jump clearance."
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

struct ControlCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.15))
                .clipShape(Circle())
                .shadow(color: color.opacity(0.35), radius: 6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(description)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.55))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 18, strokeColor: color.opacity(0.2))
    }
}

struct ObstacleRow: View {
    let title: String
    let tag: String
    let tagColor: Color
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                Text(tag)
                    .font(.system(size: 9, weight: .heavy, design: .monospaced))
                    .foregroundStyle(tagColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(tagColor.opacity(0.15))
                    .clipShape(Capsule())
            }
            Text(description)
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 18, strokeColor: tagColor.opacity(0.2))
    }
}

#Preview {
    NavigationStack {
        DinoHowToPlayView()
    }
}
