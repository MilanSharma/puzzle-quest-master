import Foundation
import StoreKit
import SwiftUI
import AppTrackingTransparency
import GoogleMobileAds

extension Notification.Name {
    static let didPurchaseGems = Notification.Name("didPurchaseGems")
    static let didPurchasePass = Notification.Name("didPurchasePass")
}

class MonetizationManager: ObservableObject {
    @Published var gemPackages: [GemPackage] = []
    @Published var recentPurchases: [Purchase] = []
    @Published var isRoyalPassActive = false
    @Published var royalPassExpiryDate = ""
    @Published var hasActiveSubscription = false
    @Published var showRoyalPassOffer = false
    
    init() { setupGemPackages() }
    
    private func setupGemPackages() {
        gemPackages = [GemPackage(gems: 100, bonus: 0, price: 0.99, originalPrice: nil, description: "Small", isBestValue: false, isLimitedTime: false)]
    }
    
    func purchaseGemPackage(_ package: GemPackage) { print("Purchased \(package.gems)") }
    func purchaseBoosterPack(_ name: String, quantity: Int, price: Double) {}
    func purchaseRoyalPass(plan: RoyalPassPlan) {}
}

class AdManager: NSObject, ObservableObject {
    @Published var interstitialAdLoaded = false
    private var interstitial: GADInterstitialAd?
    
    override init() {
        super.init()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        loadInterstitial()
    }
    
    func loadInterstitial() {
        let request = GADRequest()
        // FIXED SYNTAX: load(withAdUnitID: ...)
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3940256099942544/4411468910", request: request) { [weak self] ad, error in
            if let error = error { print("Ad Error: \(error)"); return }
            self?.interstitial = ad
            self?.interstitialAdLoaded = true
        }
    }
    
    func showInterstitial() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = windowScene.windows.first?.rootViewController,
              let ad = interstitial else { return }
        
        // FIXED SYNTAX: present(fromRootViewController:)
        ad.present(fromRootViewController: root)
        loadInterstitial()
    }
    
    func requestTracking() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { _ in }
        }
    }
}
