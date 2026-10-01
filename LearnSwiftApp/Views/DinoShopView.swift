import SwiftUI
import SceneKit

struct DinoShopView: View {
    @ObservedObject var gameManager = DinoGameManager.shared
    @State private var selectedTab: ShopTab = .skins
    @State private var previewSkin: DinoSkin = DinoGameManager.shared.equippedSkin
    
    enum ShopTab: String, CaseIterable, Identifiable {
        case skins = "3D Skins"
        case powerups = "Power-Ups"
        var id: String { rawValue }
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header Coins & Gems Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("DINO ARSENAL")
                                .font(.system(size: 10, weight: .heavy, design: .monospaced))
                                .foregroundStyle(AppTheme.purple)
                            Text("Workshop & Skins")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        
                        Spacer()
                        
                        // Tap Coins to Claim Instantly
                        Button {
                            gameManager.claimFreeCoinsAirDrop(amount: 2500)
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "circle.fill")
                                    .foregroundStyle(AppTheme.gold)
                                    .font(.system(size: 12))
                                Text("\(gameManager.coins)")
                                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                                    .foregroundStyle(.white)
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(AppTheme.gold)
                                    .font(.system(size: 13))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .glassCard(cornerRadius: 14, strokeColor: AppTheme.gold.opacity(0.4))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // UNLIMITED COIN TREASURY AIRDROP BANNER
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Label("TREASURY AIRDROP", systemImage: "sparkles")
                                .font(.system(size: 11, weight: .black, design: .monospaced))
                                .foregroundStyle(AppTheme.gold)
                            Spacer()
                            Text("UNLIMITED FREE MONEY")
                                .font(.system(size: 9, weight: .heavy, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        
                        HStack(spacing: 8) {
                            Button {
                                gameManager.claimFreeCoinsAirDrop(amount: 1000)
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "circle.fill").foregroundStyle(AppTheme.gold).font(.caption2)
                                    Text("+1,000")
                                        .font(.system(size: 12, weight: .black, design: .rounded))
                                }
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(AppTheme.goldGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            Button {
                                gameManager.claimFreeCoinsAirDrop(amount: 5000)
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "banknote.fill").foregroundStyle(.yellow).font(.caption2)
                                    Text("+5,000")
                                        .font(.system(size: 12, weight: .black, design: .rounded))
                                }
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "#00F0FF"), Color(hex: "#00E676")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            Button {
                                gameManager.claimFreeCoinsAirDrop(amount: 10000)
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "crown.fill").foregroundStyle(.white).font(.caption2)
                                    Text("+10,000")
                                        .font(.system(size: 12, weight: .black, design: .rounded))
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "#FF007F"), Color(hex: "#7928CA")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(14)
                    .glassCard(cornerRadius: 18, strokeColor: AppTheme.gold.opacity(0.35))
                    .padding(.horizontal)
                    
                    // Custom Segmented Picker
                    HStack(spacing: 8) {
                        ForEach(ShopTab.allCases) { tab in
                            Button {
                                HapticsManager.shared.selection()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedTab = tab
                                }
                            } label: {
                                Text(tab.rawValue)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(selectedTab == tab ? .black : .white.opacity(0.7))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        selectedTab == tab ?
                                        AnyShapeStyle(AppTheme.neonGreen) :
                                        AnyShapeStyle(Color.white.opacity(0.06))
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(4)
                    .glassCard(cornerRadius: 16)
                    .padding(.horizontal)
                    
                    if selectedTab == .skins {
                        skinsSection
                    } else {
                        powerupsSection
                    }
                }
                .padding(.bottom, 36)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
    
    // MARK: - Skins Section
    private var skinsSection: some View {
        VStack(spacing: 18) {
            // Live 3D Interactive Preview Box
            VStack(spacing: 12) {
                ZStack(alignment: .topTrailing) {
                    Dino3DPreviewView(skin: previewSkin)
                        .frame(height: 220)
                    
                    // 360 Tag
                    Label("360° Drag", systemImage: "arrow.triangle.2.circlepath")
                        .font(.system(size: 9, weight: .heavy, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.6))
                        .foregroundStyle(AppTheme.cyan)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(AppTheme.cyan.opacity(0.4), lineWidth: 1))
                        .padding(12)
                }
                
                VStack(spacing: 4) {
                    // Species & Chassis Badge
                    HStack(spacing: 6) {
                        Text(previewSkin.species.rawValue.uppercased())
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundStyle(previewSkin.primaryColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(previewSkin.primaryColor.opacity(0.15))
                            .clipShape(Capsule())
                        
                        Text(previewSkin.bodyType.uppercased())
                            .font(.system(size: 9, weight: .black, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    
                    Text(previewSkin.name)
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(previewSkin.description)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Action Button: Equip or Buy
                if gameManager.isSkinUnlocked(previewSkin) {
                    if gameManager.equippedSkinId == previewSkin.id {
                        Label("CURRENTLY EQUIPPED", systemImage: "checkmark.seal.fill")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundStyle(AppTheme.neonGreen)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.neonGreen.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.neonGreen.opacity(0.4), lineWidth: 1))
                            .padding(.horizontal)
                    } else {
                        Button {
                            gameManager.equipSkin(previewSkin)
                        } label: {
                            Text("EQUIP SKIN")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppTheme.cyanGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: AppTheme.cyan.opacity(0.4), radius: 8)
                        }
                        .padding(.horizontal)
                    }
                } else {
                    Button {
                        gameManager.unlockSkin(previewSkin)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "lock.open.fill")
                            Text("UNLOCK FOR")
                            Image(systemName: "circle.fill").foregroundStyle(AppTheme.gold).font(.caption)
                            Text("\(previewSkin.price)")
                        }
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            gameManager.coins >= previewSkin.price ?
                            AnyShapeStyle(AppTheme.goldGradient) :
                            AnyShapeStyle(Color.gray.opacity(0.4))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: gameManager.coins >= previewSkin.price ? AppTheme.gold.opacity(0.4) : .clear, radius: 8)
                    }
                    .disabled(gameManager.coins < previewSkin.price)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 14)
            .glassCard(cornerRadius: 24, strokeColor: previewSkin.primaryColor.opacity(0.3))
            .padding(.horizontal)
            
            // Skin Selection Cards
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Dinosaur Wardrobe (\(gameManager.availableSkins.count) Species)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                    Spacer()
                    Text("UNLOCKED \(gameManager.unlockedSkinIds.count)/\(gameManager.availableSkins.count)")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(AppTheme.neonGreen)
                }
                .padding(.horizontal)
                
                ForEach(gameManager.availableSkins) { skin in
                    SkinRowCard(
                        skin: skin,
                        isSelected: previewSkin.id == skin.id,
                        isUnlocked: gameManager.isSkinUnlocked(skin),
                        isEquipped: gameManager.equippedSkinId == skin.id,
                        onSelect: {
                            previewSkin = skin
                            HapticsManager.shared.impact(.light)
                        }
                    )
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Power-Ups Section
    private var powerupsSection: some View {
        VStack(spacing: 14) {
            ForEach(PowerUpType.allCases) { powerUp in
                PowerUpCard(powerUp: powerUp)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Skin Row Card
struct SkinRowCard: View {
    let skin: DinoSkin
    let isSelected: Bool
    let isUnlocked: Bool
    let isEquipped: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [skin.primaryColor, skin.secondaryColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: skin.iconName)
                            .foregroundStyle(.white)
                            .font(.system(size: 18))
                    )
                    .shadow(color: skin.primaryColor.opacity(0.4), radius: 6)
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(skin.name)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(skin.bodyType)
                            .font(.system(size: 9, weight: .black, design: .monospaced))
                            .foregroundStyle(skin.primaryColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(skin.primaryColor.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    Text(skin.description)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(1)
                }
                
                Spacer()
                
                if isEquipped {
                    Text("EQUIPPED")
                        .font(.system(size: 9, weight: .heavy, design: .monospaced))
                        .foregroundStyle(AppTheme.neonGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.neonGreen.opacity(0.15))
                        .clipShape(Capsule())
                } else if isUnlocked {
                    Text("OWNED")
                        .font(.system(size: 9, weight: .heavy, design: .monospaced))
                        .foregroundStyle(AppTheme.cyan)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.cyan.opacity(0.15))
                        .clipShape(Capsule())
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "circle.fill").foregroundStyle(AppTheme.gold).font(.caption2)
                        Text("\(skin.price)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .glassCard(cornerRadius: 12)
                }
            }
            .padding(12)
            .glassCard(cornerRadius: 18, strokeColor: isSelected ? AppTheme.cyan : Color.white.opacity(0.08))
        }
    }
}

// MARK: - PowerUp Card
struct PowerUpCard: View {
    @ObservedObject var gameManager = DinoGameManager.shared
    let powerUp: PowerUpType
    
    var currentLevel: Int {
        gameManager.currentLevel(for: powerUp)
    }
    
    var cost: Int {
        gameManager.upgradeCost(for: powerUp)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 14) {
                Image(systemName: powerUp.iconName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(powerUp.themeColor)
                    .frame(width: 44, height: 44)
                    .background(powerUp.themeColor.opacity(0.18))
                    .clipShape(Circle())
                    .shadow(color: powerUp.themeColor.opacity(0.35), radius: 6)
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(powerUp.rawValue)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Spacer()
                        Text("LVL \(currentLevel)")
                            .font(.system(size: 12, weight: .black, design: .monospaced))
                            .foregroundStyle(powerUp.themeColor)
                    }
                    
                    Text(powerUp.description)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.55))
                }
            }
            
            // Progress Level Bar
            HStack(spacing: 6) {
                ForEach(1...PowerUpType.maxLevel, id: \.self) { lvl in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(lvl <= currentLevel ? powerUp.themeColor : Color.white.opacity(0.1))
                        .frame(height: 6)
                        .shadow(color: lvl <= currentLevel ? powerUp.themeColor.opacity(0.5) : .clear, radius: 4)
                }
            }
            
            // Upgrade Button
            if currentLevel < PowerUpType.maxLevel {
                Button {
                    gameManager.upgradePowerUp(powerUp)
                } label: {
                    HStack {
                        Text("Upgrade to Level \(currentLevel + 1)")
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "circle.fill").foregroundStyle(AppTheme.gold).font(.caption)
                            Text("\(cost)")
                        }
                    }
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(
                        gameManager.coins >= cost ?
                        AnyShapeStyle(powerUp.themeColor) :
                        AnyShapeStyle(Color.gray.opacity(0.4))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: gameManager.coins >= cost ? powerUp.themeColor.opacity(0.4) : .clear, radius: 6)
                }
                .disabled(gameManager.coins < cost)
            } else {
                Text("MAX LEVEL REACHED")
                    .font(.system(size: 10, weight: .heavy, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.vertical, 6)
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 20, strokeColor: powerUp.themeColor.opacity(0.25))
    }
}

#Preview {
    NavigationStack {
        DinoShopView()
    }
}
