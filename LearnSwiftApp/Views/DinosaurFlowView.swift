import SwiftUI

struct DinosaurFlowView: View {
    @State private var path: [Route] = []
    
    enum Route: Hashable {
        case play3D
        case shop
        case missions
        case highScore
        case howToPlay
        case settings
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            DinoHomeView(
                onPlay: { path.append(.play3D) },
                onShop: { path.append(.shop) },
                onMissions: { path.append(.missions) },
                onHighScores: { path.append(.highScore) },
                onHowToPlay: { path.append(.howToPlay) },
                onSettings: { path.append(.settings) }
            )
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .play3D:
                    Dino3DRunnerView(onExitToHome: {
                        path = []
                    })
                case .shop:
                    DinoShopView()
                case .missions:
                    DinoMissionsView()
                case .highScore:
                    DinoHighScoreView()
                case .howToPlay:
                    DinoHowToPlayView()
                case .settings:
                    DinoSettingsView()
                }
            }
        }
    }
}

#Preview {
    DinosaurFlowView()
}
