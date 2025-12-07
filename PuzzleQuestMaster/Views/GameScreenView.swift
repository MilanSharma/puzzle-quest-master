
import SwiftUI
struct GameScreenView: View {
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var adManager: AdManager
    var body: some View {
        VStack {
            Text("Score: \(gameManager.currentScore)")
            Button("Win Level (Test)") {
                adManager.showInterstitial()
                gameManager.nextLevel()
            }
        }
    }
}
