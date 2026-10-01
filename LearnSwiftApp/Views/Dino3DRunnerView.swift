import SwiftUI
import SceneKit

struct Dino3DRunnerView: View {
    @ObservedObject var gameManager = DinoGameManager.shared
    var onExitToHome: () -> Void
    
    @State private var scene = Dino3DScene()
    @State private var score: Int = 0
    @State private var distance: Int = 0
    @State private var runCoins: Int = 0
    @State private var obstaclesCleared: Int = 0
    
    @State private var isPaused: Bool = false
    @State private var isGameOver: Bool = false
    @State private var isNewHighScore: Bool = false
    
    @State private var hasShieldActive: Bool = false
    @State private var hasMagnetActive: Bool = false
    
    // Feedback proxy coordinator
    private let coordinator = GameSceneCoordinator()
    
    var body: some View {
        ZStack {
            // 3D Scene View
            SceneKitView(scene: scene)
                .ignoresSafeArea()
                .gesture(
                    DragGesture(minimumDistance: 15)
                        .onEnded { value in
                            if value.translation.height < -20 {
                                performJump()
                            } else if value.translation.height > 20 {
                                performDuck()
                            }
                        }
                )
                .onTapGesture {
                    performJump()
                }
            
            // HUD Overlay (In-Game)
            if !isGameOver {
                VStack {
                    // Top Bar HUD
                    HStack(alignment: .center) {
                        // Current Score & Distance
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text("\(score)")
                                    .font(.system(size: 34, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2)
                                
                                Text("PTS")
                                    .font(.system(size: 12, weight: .black, design: .monospaced))
                                    .foregroundStyle(AppTheme.gold)
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "figure.run")
                                    .font(.system(size: 11))
                                Text("\(distance)m")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(.white.opacity(0.85))
                        }
                        
                        Spacer()
                        
                        // Active Power-up Badges
                        HStack(spacing: 6) {
                            if hasShieldActive {
                                Label("SHIELD", systemImage: "shield.fill")
                                    .font(.system(size: 9, weight: .heavy, design: .monospaced))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(AppTheme.cyan.opacity(0.85))
                                    .foregroundStyle(.black)
                                    .clipShape(Capsule())
                                    .shadow(color: AppTheme.cyan.opacity(0.5), radius: 6)
                            }
                            
                            if hasMagnetActive {
                                Label("MAGNET", systemImage: "arrow.down.to.line.circle.fill")
                                    .font(.system(size: 9, weight: .heavy, design: .monospaced))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(AppTheme.purple.opacity(0.85))
                                    .foregroundStyle(.white)
                                    .clipShape(Capsule())
                                    .shadow(color: AppTheme.purple.opacity(0.5), radius: 6)
                            }
                        }
                        
                        // Coins Counter
                        HStack(spacing: 5) {
                            Image(systemName: "circle.fill")
                                .foregroundStyle(AppTheme.gold)
                                .font(.system(size: 12))
                            Text("\(runCoins)")
                                .font(.system(size: 16, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .glassCard(cornerRadius: 14, strokeColor: AppTheme.gold.opacity(0.3))
                        
                        // Pause Button
                        Button {
                            togglePause()
                        } label: {
                            Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 38, height: 38)
                                .glassCard(cornerRadius: 19)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 50)
                    
                    Spacer()
                    
                    // Bottom On-Screen Action Touch Controls
                    HStack(spacing: 24) {
                        Button {
                            performDuck()
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "arrow.down.to.line")
                                    .font(.system(size: 22, weight: .bold))
                                Text("DUCK")
                                    .font(.system(size: 10, weight: .heavy, design: .monospaced))
                            }
                            .foregroundStyle(.white)
                            .frame(width: 72, height: 72)
                            .background(Color(hex: "#101622").opacity(0.75))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1.5))
                            .shadow(color: .black.opacity(0.4), radius: 8)
                        }
                        
                        Spacer()
                        
                        Button {
                            performJump()
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 26, weight: .bold))
                                Text("JUMP")
                                    .font(.system(size: 10, weight: .heavy, design: .monospaced))
                            }
                            .foregroundStyle(.black)
                            .frame(width: 82, height: 82)
                            .background(AppTheme.playButtonGradient)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 2))
                            .shadow(color: AppTheme.neonGreen.opacity(0.5), radius: 12, x: 0, y: 6)
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 36)
                }
            }
            
            // Pause Modal
            if isPaused && !isGameOver {
                ZStack {
                    Color.black.opacity(0.7).ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Text("GAME PAUSED")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        
                        VStack(spacing: 12) {
                            Button {
                                togglePause()
                            } label: {
                                Label("Resume", systemImage: "play.fill")
                                    .font(.headline.bold())
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(AppTheme.neonGreen)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            
                            Button {
                                restartGame()
                            } label: {
                                Label("Restart", systemImage: "arrow.clockwise")
                                    .font(.headline.bold())
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .glassCard(cornerRadius: 14)
                            }
                            
                            Button {
                                onExitToHome()
                            } label: {
                                Label("Quit to Menu", systemImage: "house.fill")
                                    .font(.headline.bold())
                                    .foregroundStyle(AppTheme.coral)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(AppTheme.coral.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.coral.opacity(0.3), lineWidth: 1))
                            }
                        }
                        .frame(width: 240)
                    }
                    .padding(32)
                    .glassCard(cornerRadius: 24)
                }
            }
            
            // Game Over Scorecard Overlay
            if isGameOver {
                ZStack {
                    Color.black.opacity(0.78).ignoresSafeArea()
                    
                    VStack(spacing: 18) {
                        // Trophy / New Best Badge
                        if isNewHighScore {
                            VStack(spacing: 6) {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 52))
                                    .foregroundStyle(AppTheme.goldGradient)
                                    .shadow(color: AppTheme.gold.opacity(0.7), radius: 16)
                                Text("NEW RECORD ACHIEVED!")
                                    .font(.system(size: 15, weight: .black, design: .monospaced))
                                    .foregroundStyle(AppTheme.gold)
                            }
                        } else {
                            Image(systemName: "xmark.octagon.fill")
                                .font(.system(size: 46))
                                .foregroundStyle(AppTheme.coral)
                                .shadow(color: AppTheme.coral.opacity(0.5), radius: 10)
                        }
                        
                        Text("GAME OVER")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        
                        // Score Summary Card
                        VStack(spacing: 12) {
                            HStack {
                                Text("Final Run Score")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white.opacity(0.6))
                                Spacer()
                                Text("\(score)")
                                    .font(.system(size: 22, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                            
                            HStack {
                                Text("Distance Survived")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white.opacity(0.6))
                                Spacer()
                                Text("\(distance) m")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppTheme.cyan)
                            }
                            
                            HStack {
                                Text("Gold Collected")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white.opacity(0.6))
                                Spacer()
                                HStack(spacing: 4) {
                                    Image(systemName: "circle.fill").foregroundStyle(AppTheme.gold).font(.caption)
                                    Text("+\(runCoins)")
                                        .font(.system(size: 18, weight: .black, design: .rounded))
                                        .foregroundStyle(AppTheme.gold)
                                }
                            }
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            HStack {
                                Text("All-Time Best")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white.opacity(0.6))
                                Spacer()
                                Text("\(gameManager.highScore)")
                                    .font(.system(size: 20, weight: .black, design: .rounded))
                                    .foregroundStyle(AppTheme.neonGreen)
                            }
                        }
                        .padding(18)
                        .glassCard(cornerRadius: 18)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            Button {
                                restartGame()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Play Again")
                                }
                                .font(.headline.bold())
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppTheme.playButtonGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: AppTheme.neonGreen.opacity(0.4), radius: 8, y: 4)
                            }
                            
                            Button {
                                onExitToHome()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "house.fill")
                                    Text("Main Menu")
                                }
                                .font(.headline.bold())
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .glassCard(cornerRadius: 14)
                            }
                        }
                    }
                    .padding(26)
                    .frame(maxWidth: 340)
                    .glassCard(cornerRadius: 24, strokeColor: isNewHighScore ? AppTheme.gold.opacity(0.5) : AppTheme.coral.opacity(0.3))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            startGameSession()
        }
    }
    
    // MARK: - Game Actions
    private func startGameSession() {
        let skin = gameManager.equippedSkin
        scene.applySkin(skin)
        
        hasShieldActive = (gameManager.shieldLevel >= 2)
        hasMagnetActive = (gameManager.magnetLevel >= 2)
        scene.hasShield = hasShieldActive
        scene.hasMagnet = hasMagnetActive
        
        scene.gameDelegate = coordinator
        coordinator.onScoreUpdate = { s, d, c in
            self.score = s
            self.distance = d
            self.runCoins = c
        }
        coordinator.onCoinPickup = {
            HapticsManager.shared.impact(.light)
            AudioService.shared.playCoinSound()
        }
        coordinator.onShieldBreak = {
            hasShieldActive = false
            HapticsManager.shared.notification(.warning)
            AudioService.shared.playShieldBreakSound()
        }
        coordinator.onGameOver = { s, d, c, obs in
            handleGameOver(score: s, distance: d, coins: c, obstaclesCleared: obs)
        }
        
        restartGame()
    }
    
    private func performJump() {
        guard !isGameOver, !isPaused else { return }
        scene.jump()
        HapticsManager.shared.impact(.light)
        AudioService.shared.playJumpSound()
    }
    
    private func performDuck() {
        guard !isGameOver, !isPaused else { return }
        scene.startDuck()
        HapticsManager.shared.impact(.rigid)
    }
    
    private func togglePause() {
        isPaused.toggle()
        if isPaused {
            scene.pauseGame()
        } else {
            scene.resumeGame()
        }
        HapticsManager.shared.impact(.medium)
        AudioService.shared.playTapSound()
    }
    
    private func restartGame() {
        isGameOver = false
        isPaused = false
        isNewHighScore = false
        score = 0
        distance = 0
        runCoins = 0
        obstaclesCleared = 0
        
        hasShieldActive = (gameManager.shieldLevel >= 2)
        hasMagnetActive = (gameManager.magnetLevel >= 2)
        scene.hasShield = hasShieldActive
        scene.hasMagnet = hasMagnetActive
        
        scene.startGame()
    }
    
    private func handleGameOver(score: Int, distance: Int, coins: Int, obstaclesCleared: Int) {
        self.score = score
        self.distance = distance
        self.runCoins = coins
        self.obstaclesCleared = obstaclesCleared
        
        isNewHighScore = score > gameManager.highScore
        gameManager.recordRun(score: score, coinsCollected: coins, obstaclesCleared: obstaclesCleared)
        
        AudioService.shared.playGameOverSound()
        
        if isNewHighScore {
            HapticsManager.shared.notification(.success)
        } else {
            HapticsManager.shared.notification(.error)
        }
        
        withAnimation(.spring()) {
            isGameOver = true
        }
    }
}

// MARK: - SceneKit UIViewRepresentable Wrapper
private struct SceneKitView: UIViewRepresentable {
    let scene: Dino3DScene
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = scene
        scnView.delegate = scene
        scnView.isPlaying = true
        scnView.antialiasingMode = .multisampling4X
        scnView.preferredFramesPerSecond = 60
        scnView.backgroundColor = UIColor(Color(hex: "#0B0E14"))
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {}
}

// MARK: - Coordinator Proxy
private class GameSceneCoordinator: Dino3DGameDelegate {
    var onScoreUpdate: ((Int, Int, Int) -> Void)?
    var onCoinPickup: (() -> Void)?
    var onShieldBreak: (() -> Void)?
    var onGameOver: ((Int, Int, Int, Int) -> Void)?
    
    func dinoDidUpdateScore(_ score: Int, distance: Int, coins: Int) {
        DispatchQueue.main.async {
            self.onScoreUpdate?(score, distance, coins)
        }
    }
    func dinoDidCollectCoin() {
        DispatchQueue.main.async {
            self.onCoinPickup?()
        }
    }
    func dinoDidTriggerShieldBreak() {
        DispatchQueue.main.async {
            self.onShieldBreak?()
        }
    }
    func dinoDidGameOver(score: Int, distance: Int, coins: Int, obstaclesCleared: Int) {
        DispatchQueue.main.async {
            self.onGameOver?(score, distance, coins, obstaclesCleared)
        }
    }
}

#Preview {
    Dino3DRunnerView(onExitToHome: {})
}
