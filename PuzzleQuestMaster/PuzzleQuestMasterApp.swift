
import SwiftUI

@main
struct PuzzleQuestMasterApp: App {
    @StateObject private var gameManager = GameManager()
    @StateObject private var monetizationManager = MonetizationManager()
    @StateObject private var adManager = AdManager()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameManager)
                .environmentObject(monetizationManager)
                .environmentObject(adManager)
                .onAppear {
                    CloudSaveManager.shared.initialize()
                }
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    if newPhase == .active {
                        adManager.requestTracking()
                    }
                }
        }
    }
}
