
import SwiftUI

struct ShopScreenView: View {
    @EnvironmentObject var monetizationManager: MonetizationManager
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Store")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text("Gems: \(gameManager.player.gems)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Royal Pass Banner
                    Button(action: { /* Navigate to detailed pass view */ }) {
                        ZStack {
                            LinearGradient(gradient: Gradient(colors: [Color.accentGoldDark, Color.accentGold]), startPoint: .leading, endPoint: .trailing)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("ROYAL PASS")
                                        .font(.title2)
                                        .fontWeight(.heavy)
                                        .foregroundColor(.white)
                                    Text("No Ads + Daily Rewards")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                Spacer()
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }
                    }
                    .frame(height: 100)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    .shadow(color: .accentGold.opacity(0.4), radius: 8, x: 0, y: 4)
                    .buttonStyle(ScaleButtonStyle())
                    
                    // Gem Packages Grid
                    VStack(alignment: .leading) {
                        Text("Gem Packs")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(monetizationManager.gemPackages) { pkg in
                                ShopItemCard(package: pkg) {
                                    monetizationManager.purchaseGemPackage(pkg)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Restore Purchases
                    Button("Restore Purchases") {
                        // Restore logic
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 20)
                }
                .padding(.vertical)
            }
            .background(Color.neutral50.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

struct ShopItemCard: View {
    let package: GemPackage
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                if package.isBestValue {
                    Text("BEST VALUE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(4)
                }
                
                Image(systemName: "suit.diamond.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("\(package.gems) Gems")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if package.bonus > 0 {
                    Text("+\(package.bonus) Bonus")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                Text("$\(String(format: "%.2f", package.price))")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.primaryBlue)
                    .cornerRadius(20)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white)
            .cornerRadius(16)
            .cardShadow()
        }
        .buttonStyle(BounceButtonStyle())
    }
}
