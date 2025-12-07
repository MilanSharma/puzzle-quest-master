
import SwiftUI
struct HomeScreenView: View {
    @EnvironmentObject var gameManager: GameManager
    var body: some View {
        VStack {
            Text("Puzzle Quest Master").font(.largeTitle).padding()
            Button("Play Level \(gameManager.currentLevel)") {}
            Text("Gems: \(gameManager.player.gems)")
        }
    }
}
