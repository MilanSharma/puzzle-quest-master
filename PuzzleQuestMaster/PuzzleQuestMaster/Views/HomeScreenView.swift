import SwiftUI

struct HomeScreenView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Puzzle Quest Master").font(.largeTitle).bold().foregroundColor(.primaryBlue)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Stats").font(.headline)
                        HStack {
                            Text("💎 \(gameManager.player.gems)")
                            Spacer()
                            Text("💰 \(gameManager.player.coins)")
                        }
                        .padding()
                        .background(Color.neutral100)
                        .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Daily Challenges").font(.headline)
                        ForEach(gameManager.dailyChallenges) { challenge in
                            HStack {
                                Text(challenge.icon)
                                VStack(alignment: .leading) {
                                    Text(challenge.title).bold()
                                    // FIXED: Double casting
                                    ProgressView(value: Double(challenge.progress), total: Double(challenge.target))
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                        }
                    }
                    
                    Button("Play Level \(gameManager.currentLevel)") {
                        // Action handled in tab view
                    }
                    .padding()
                    .background(Color.primaryBlue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}
