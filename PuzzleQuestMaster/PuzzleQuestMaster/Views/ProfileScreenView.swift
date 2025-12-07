import SwiftUI

struct ProfileScreenView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Profile")) {
                    Text("Player Level: \(gameManager.player.level)")
                    Text("Total Stars: \(gameManager.player.totalStars)")
                }
                
                Section(header: Text("Settings")) {
                    Toggle("Sound", isOn: $gameManager.settings.soundEnabled)
                    Toggle("Notifications", isOn: $gameManager.settings.notificationsEnabled)
                }
            }
            .navigationTitle("Profile")
        }
    }
}
