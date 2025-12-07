
import SwiftUI
struct ProfileScreenView: View {
    @EnvironmentObject var gameManager: GameManager
    var body: some View {
        List {
            Text("Player: \(gameManager.player.name)")
            Text("Level: \(gameManager.player.level)")
        }
    }
}
