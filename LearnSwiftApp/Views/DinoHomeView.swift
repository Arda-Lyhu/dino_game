import SwiftUI
import SceneKit

struct DinoHomeView: View {
    @ObservedObject var gameManager = DinoGameManager.shared
    var onPlay: () -> Void
    var onShop: () -> Void
    var onMissions: () -> Void
    var onHighScores: () -> Void
    var onHowToPlay: () -> Void
    var onSettings: () -> Void
    
    @State private var isPulsingPlayButton: Bool = false
    
    var body: some View {
        ZStack {
            // Background Dark Cyber Gradient
            AppTheme.backgroundGradient.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    // Top Currency & Player Level Glass Bar
                    HStack(spacing: 10) {
                        // Level Badge
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(AppTheme.neonGreen)
                            Text("LVL \(max(1, gameManager.totalRuns / 3 + 1))")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .glassCard(cornerRadius: 14, strokeColor: AppTheme.neonGreen.opacity(0.3))
                        
                        Spacer()
                        
                        // Coins with + Free Button
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
                        
                        // Gems
                        HStack(spacing: 5) {
                            Image(systemName: "suit.diamond.fill")
                                .foregroundStyle(AppTheme.cyan)
                                .font(.system(size: 12))
                            Text("\(gameManager.gems)")
                                .font(.system(size: 14, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .glassCard(cornerRadius: 14, strokeColor: AppTheme.cyan.opacity(0.3))
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // 3D Hero Pedestal Card
                    VStack(spacing: 0) {
                        ZStack(alignment: .bottom) {
                            // 3D Interactive Dinosaur Showcase
                            Dino3DPreviewView(skin: gameManager.equippedSkin)
                                .frame(height: 240)
                            
                            // Bottom Skin Label Bar
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("EQUIPPED RUNNER")
                                        .font(.system(size: 9, weight: .heavy, design: .monospaced))
                                        .foregroundStyle(gameManager.equippedSkin.primaryColor)
                                    Text(gameManager.equippedSkin.name)
                                        .font(.system(size: 18, weight: .black, design: .rounded))
                                        .foregroundStyle(.white)
                                }
                                
                                Spacer()
                                
                                Button {
                                    HapticsManager.shared.impact(.light)
                                    onShop()
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 11))
                                        Text("CUSTOMIZE")
                                            .font(.system(size: 11, weight: .black, design: .rounded))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(
                                        LinearGradient(
                                            colors: [gameManager.equippedSkin.primaryColor, gameManager.equippedSkin.secondaryColor],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundStyle(.white)
                                    .clipShape(Capsule())
                                    .shadow(color: gameManager.equippedSkin.primaryColor.opacity(0.4), radius: 6)
                                }
                            }
                            .padding(14)
                            .background(Color(hex: "#0E131E").opacity(0.92))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(10)
                        }
                    }
                    .glassCard(cornerRadius: 24, strokeColor: gameManager.equippedSkin.primaryColor.opacity(0.4))
                    .padding(.horizontal)
                    
                    // BIG GLOWING PLAY BUTTON
                    Button {
                        HapticsManager.shared.impact(.heavy)
                        AudioService.shared.playTapSound()
                        onPlay()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 24, weight: .black))
                            Text("START 3D RUN")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 62)
                        .background(AppTheme.playButtonGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: AppTheme.neonGreen.opacity(0.45), radius: 14, x: 0, y: 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                        )
                    }
                    .padding(.horizontal)
                    
                    // Quick Stats Ribbon (Obsidian Glass)
                    HStack(spacing: 10) {
                        StatPill(icon: "trophy.fill", title: "Best Score", value: "\(gameManager.highScore)", color: AppTheme.gold)
                        StatPill(icon: "flame.fill", title: "Total Runs", value: "\(gameManager.totalRuns)", color: AppTheme.coral)
                        StatPill(icon: "shield.checkered", title: "Cleared", value: "\(gameManager.totalObstaclesCleared)", color: AppTheme.neonGreen)
                    }
                    .padding(.horizontal)
                    
                    // Menu Grid (Shop, Missions, High Scores, Guide)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        MenuTile(
                            icon: "bag.fill",
                            title: "Dino Shop",
                            subtitle: "Skins & Upgrades",
                            accentColor: AppTheme.purple,
                            action: {
                                HapticsManager.shared.impact(.light)
                                onShop()
                            }
                        )
                        
                        MenuTile(
                            icon: "flag.checkered.2.crossed",
                            title: "Missions",
                            subtitle: "\(gameManager.missions.filter { $0.isCompleted && !$0.isClaimed }.count) Claimable",
                            accentColor: AppTheme.coral,
                            action: {
                                HapticsManager.shared.impact(.light)
                                onMissions()
                            }
                        )
                        
                        MenuTile(
                            icon: "chart.bar.xaxis",
                            title: "High Scores",
                            subtitle: "Stats & Records",
                            accentColor: AppTheme.cyan,
                            action: {
                                HapticsManager.shared.impact(.light)
                                onHighScores()
                            }
                        )
                        
                        MenuTile(
                            icon: "book.fill",
                            title: "How to Play",
                            subtitle: "Controls & Guide",
                            accentColor: AppTheme.neonGreen,
                            action: {
                                HapticsManager.shared.impact(.light)
                                onHowToPlay()
                            }
                        )
                    }
                    .padding(.horizontal)
                    
                    // Settings Button
                    Button {
                        HapticsManager.shared.impact(.light)
                        onSettings()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.white.opacity(0.8))
                            Text("Game Settings")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .glassCard(cornerRadius: 16)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

// MARK: - Stat Pill Subcomponent
struct StatPill: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundStyle(color)
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
            }
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .glassCard(cornerRadius: 16, strokeColor: color.opacity(0.25))
    }
}

// MARK: - Menu Tile Subcomponent
struct MenuTile: View {
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(accentColor)
                        .frame(width: 38, height: 38)
                        .background(accentColor.opacity(0.18))
                        .clipShape(Circle())
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white.opacity(0.3))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(1)
                }
            }
            .padding(14)
            .glassCard(cornerRadius: 18, strokeColor: accentColor.opacity(0.25))
        }
    }
}

// MARK: - 3D Interactive Dino Preview (SceneKit)
struct Dino3DPreviewView: UIViewRepresentable {
    let skin: DinoSkin
    
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = false
        view.backgroundColor = .clear
        view.scene = makeScene()
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene = makeScene()
    }
    
    private func makeScene() -> SCNScene {
        let scene = SCNScene()
        
        // Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0.4, 3.8)
        scene.rootNode.addChildNode(cameraNode)
        
        // Lights
        let sun = SCNNode()
        let sunLight = SCNLight()
        sunLight.type = .directional
        sunLight.color = UIColor.white
        sun.light = sunLight
        sun.position = SCNVector3(5, 5, 5)
        scene.rootNode.addChildNode(sun)
        
        let ambient = SCNNode()
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor(white: 0.75, alpha: 1.0)
        ambient.light = ambientLight
        scene.rootNode.addChildNode(ambient)
        
        // Spotlight Pedestal Platform
        let platformGeo = SCNCylinder(radius: 1.4, height: 0.08)
        let platMat = SCNMaterial()
        platMat.diffuse.contents = UIColor(red: 0.12, green: 0.16, blue: 0.24, alpha: 1.0)
        platMat.roughness.contents = 0.4
        platformGeo.materials = [platMat]
        let platformNode = SCNNode(geometry: platformGeo)
        platformNode.position = SCNVector3(0, -0.65, 0)
        scene.rootNode.addChildNode(platformNode)
        
        // Build 3D Dino via Dino3DBuilder
        let dinoResult = Dino3DBuilder.buildDino(for: skin, isPreview: true)
        let dino = dinoResult.rootNode
        dino.position = SCNVector3(0, -0.6, 0)
        
        // Idle 360° Spin Animation
        let spin = CABasicAnimation(keyPath: "rotation")
        spin.fromValue = SCNVector4(0, 1, 0, 0)
        spin.toValue = SCNVector4(0, 1, 0, Float.pi * 2)
        spin.duration = 9.0
        spin.repeatCount = .infinity
        dino.addAnimation(spin, forKey: "spin")
        
        scene.rootNode.addChildNode(dino)
        return scene
    }
}

#Preview {
    NavigationStack {
        DinoHomeView(
            onPlay: {},
            onShop: {},
            onMissions: {},
            onHighScores: {},
            onHowToPlay: {},
            onSettings: {}
        )
    }
}
