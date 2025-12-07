import SwiftUI

struct ShopScreenView: View {
    @EnvironmentObject var monetizationManager: MonetizationManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Shop").font(.largeTitle).bold()
                    
                    ForEach(monetizationManager.gemPackages) { package in
                        Button(action: { monetizationManager.purchaseGemPackage(package) }) {
                            HStack {
                                Text("\(package.gems) 💎")
                                Spacer()
                                Text("$\(String(format: "%.2f", package.price))")
                                    .padding(8)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding()
                            .background(Color.neutral100)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
        }
    }
}
