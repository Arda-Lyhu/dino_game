import SwiftUI

struct DinoSettingsView: View {
    @ObservedObject var gameManager = DinoGameManager.shared
    @State private var showingResetAlert = false
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Audio Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("AUDIO & HAPTICS")
                            .font(.system(size: 10, weight: .heavy, design: .monospaced))
                            .foregroundStyle(AppTheme.neonGreen)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            SettingToggleRow(
                                icon: "speaker.wave.2.fill",
                                title: "Sound Effects",
                                subtitle: "8-Bit retro procedural audio",
                                color: AppTheme.neonGreen,
                                isOn: $gameManager.soundEnabled
                            )
                            
                            Divider().background(Color.white.opacity(0.08))
                            
                            SettingToggleRow(
                                icon: "iphone.radiowaves.left.and.right",
                                title: "Haptic Feedback",
                                subtitle: "Vibrations on jump, collision & coins",
                                color: AppTheme.cyan,
                                isOn: $gameManager.hapticsEnabled
                            )
                        }
                        .glassCard(cornerRadius: 18)
                        .padding(.horizontal)
                    }
                    .padding(.top, 10)
                    
                    // Visuals Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("GRAPHICS & RENDERING")
                            .font(.system(size: 10, weight: .heavy, design: .monospaced))
                            .foregroundStyle(AppTheme.purple)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            SettingToggleRow(
                                icon: "cube.transparent.fill",
                                title: "4X Multisample Antialiasing",
                                subtitle: "Smoother 3D geometry edges",
                                color: AppTheme.purple,
                                isOn: $gameManager.highGraphics
                            )
                        }
                        .glassCard(cornerRadius: 18)
                        .padding(.horizontal)
                    }
                    
                    // Danger Zone / Reset
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DATA MANAGEMENT")
                            .font(.system(size: 10, weight: .heavy, design: .monospaced))
                            .foregroundStyle(AppTheme.coral)
                            .padding(.horizontal)
                        
                        Button {
                            HapticsManager.shared.impact(.heavy)
                            showingResetAlert = true
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(AppTheme.coral)
                                    .frame(width: 36, height: 36)
                                    .background(AppTheme.coral.opacity(0.15))
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Reset All Save Data")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundStyle(AppTheme.coral)
                                    Text("Clears best high scores and upgrades")
                                        .font(.system(size: 11))
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                                Spacer()
                            }
                            .padding(14)
                        }
                        .glassCard(cornerRadius: 18, strokeColor: AppTheme.coral.opacity(0.3))
                        .padding(.horizontal)
                    }
                    
                    // App Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SYSTEM INFO")
                            .font(.system(size: 10, weight: .heavy, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.4))
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Game Version")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.7))
                                Spacer()
                                Text("2.5 (Cyber Edition)")
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundStyle(.white)
                            }
                            
                            Divider().background(Color.white.opacity(0.08))
                            
                            HStack {
                                Text("3D Engine")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.7))
                                Spacer()
                                Text("Apple SceneKit & SwiftUI")
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundStyle(AppTheme.cyan)
                            }
                        }
                        .padding(16)
                        .glassCard(cornerRadius: 18)
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 36)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .alert("Reset All Save Data?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset Everything", role: .destructive) {
                gameManager.resetAllData()
            }
        } message: {
            Text("This will wipe your all-time high score, currency, missions, and upgrades.")
        }
    }
}

struct SettingToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.5))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(color)
                .onChange(of: isOn) { _ in
                    HapticsManager.shared.selection()
                }
        }
        .padding(14)
    }
}

#Preview {
    NavigationStack {
        DinoSettingsView()
    }
}
