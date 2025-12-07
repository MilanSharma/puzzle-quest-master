import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var monetizationManager: MonetizationManager
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeScreenView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            GameScreenView()
                .tabItem {
                    Image(systemName: "gamecontroller.fill")
                    Text("Play")
                }
                .tag(1)
            
            ShopScreenView()
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Shop")
                }
                .tag(2)
            
            ProfileScreenView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(.primaryBlue)
        .background(Color.neutral50)
    }
}

#Preview {
    ContentView()
        .environmentObject(GameManager())
        .environmentObject(MonetizationManager())
        .environmentObject(AdManager())
}