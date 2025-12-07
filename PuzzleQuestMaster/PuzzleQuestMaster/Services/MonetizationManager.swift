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
    @Published var isRoyalPassActive: Bool = false
    @Published var royalPassExpiryDate: String = ""
    @Published var hasActiveSubscription: Bool = false
    @Published var showRoyalPassOffer: Bool = false
    
    private let productIdentifiers = [
        "com.puzzlequest.gems.small",
        "com.puzzlequest.gems.medium",
        "com.puzzlequest.gems.large",
        "com.puzzlequest.gems.mega",
        "com.puzzlequest.royalpass.monthly",
        "com.puzzlequest.royalpass.yearly"
    ]
    
    private var transactionListener: Task<Void, Never>?
    
    init() {
        setupGemPackages()
        setupTransactionListener()
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    private func setupGemPackages() {
        gemPackages = [
            GemPackage(gems: 100, bonus: 0, price: 0.99, originalPrice: nil, description: "Starter pack", isBestValue: false, isLimitedTime: false),
            GemPackage(gems: 500, bonus: 10, price: 4.99, originalPrice: 5.99, description: "Popular", isBestValue: false, isLimitedTime: false),
            GemPackage(gems: 1200, bonus: 25, price: 9.99, originalPrice: 12.99, description: "Best Value", isBestValue: true, isLimitedTime: false),
            GemPackage(gems: 2500, bonus: 50, price: 19.99, originalPrice: 24.99, description: "Mega Pack", isBestValue: false, isLimitedTime: true)
        ]
    }
    
    private func setupTransactionListener() {
        transactionListener = Task.detached(priority: .background) { [weak self] in
            for await verification in Transaction.updates {
                if case .verified(let transaction) = verification {
                    await self?.handle(transaction)
                    await transaction.finish()
                }
            }
        }
    }
    
    @MainActor
    private func handle(_ transaction: Transaction) async {
        if let gemPackage = gemPackages.first(where: { $0.id.uuidString == transaction.productID }) {
            NotificationCenter.default.post(name: .didPurchaseGems, object: nil, userInfo: ["amount": gemPackage.gems])
            let purchase = Purchase(title: "\(gemPackage.gems) Gems", amount: gemPackage.price, date: Date().formatted(), isSubscription: false, productId: transaction.productID)
            recentPurchases.insert(purchase, at: 0)
        } else if transaction.productID.contains("royalpass") {
            isRoyalPassActive = true
            hasActiveSubscription = true
            royalPassExpiryDate = transaction.expirationDate?.formatted(date: .medium, time: .none) ?? ""
            NotificationCenter.default.post(name: .didPurchasePass, object: nil)
        }
    }
    
    func purchaseGemPackage(_ package: GemPackage) {
        Task {
            do {
                if let product = try await Product.products(for: [package.id.uuidString]).first {
                    let result = try await product.purchase()
                    switch result {
                    case .success(let verification):
                        if case .verified(let transaction) = verification {
                            await handle(transaction)
                            await transaction.finish()
                        }
                    case .userCancelled, .pending: break
                    @unknown default: break
                    }
                } else {
                    print("Product ID not found: \(package.id.uuidString)")
                }
            } catch {
                print("Purchase failed: \(error)")
            }
        }
    }
    
    func purchaseRoyalPass(plan: RoyalPassPlan) {}
    func purchaseExtraMoves() {}
    func purchaseBoosterPack(_ name: String, quantity: Int, price: Double) {}
}


class AdManager: NSObject, ObservableObject {
    @Published var interstitialAdLoaded: Bool = false
    private var interstitial: GADInterstitialAd?
    
    private let adUnitID = "ca-app-pub-3940256099942544/4411468910"
    
    override init() {
        super.init()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        loadInterstitial()
    }
    
    func loadInterstitial() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: adUnitID, request: request) { [weak self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad: \(error.localizedDescription)")
                return
            }
            self?.interstitial = ad
            self?.interstitialAdLoaded = true
        }
    }
    
    func showInterstitial() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController,
              let ad = interstitial else {
            return
        }
        
        ad.present(fromRootViewController: rootVC)
        loadInterstitial()
    }
    
    func requestTracking() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { _ in }
            }
        }
    }
}


class CloudSaveManager {
    static let shared = CloudSaveManager()
    func initialize() { NSUbiquitousKeyValueStore.default.synchronize() }
    func saveGameData(_ data: Data) {
        NSUbiquitousKeyValueStore.default.set(data, forKey: "game_save")
        NSUbiquitousKeyValueStore.default.synchronize()
    }
}
