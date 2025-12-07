
import SwiftUI
struct ShopScreenView: View {
    @EnvironmentObject var monetizationManager: MonetizationManager
    var body: some View {
        List(monetizationManager.gemPackages) { pkg in
            Button("Buy \(pkg.gems) Gems - $\(pkg.price)") {
                monetizationManager.purchaseGemPackage(pkg)
            }
        }
    }
}
