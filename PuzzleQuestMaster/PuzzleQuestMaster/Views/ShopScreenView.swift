import SwiftUI

struct ShopScreenView: View {
    @EnvironmentObject var monetizationManager: MonetizationManager
    @EnvironmentObject var gameManager: GameManager
    
    @State private var selectedCategory = ShopCategory.gems
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ShopCategoryTabs(selectedCategory: $selectedCategory)
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        switch selectedCategory {
                        case .gems:
                            GemsShopSection()
                        case .boosters:
                            BoostersShopSection()
                        case .royalPass:
                            RoyalPassSection()
                        case .specialOffers:
                            SpecialOffersSection()
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.primaryBlue)
                    }
                }
            }
        }
        .sheet(isPresented: $monetizationManager.showRoyalPassOffer) {
            RoyalPassOfferModal()
        }
    }
}

struct ShopCategoryTabs: View {
    @Binding var selectedCategory: ShopCategory
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(ShopCategory.allCases, id: \.self) { category in
                Button(action: { selectedCategory = category }) {
                    Text(category.rawValue)
                        .font(.caption.weight(.bold))
                        .foregroundColor(selectedCategory == category ? .white : .primaryBlue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            selectedCategory == category 
                            ? Color.primaryBlue 
                            : Color.clear
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.primaryBlue, lineWidth: selectedCategory == category ? 0 : 2)
                        )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
}

struct GemsShopSection: View {
    @EnvironmentObject var monetizationManager: MonetizationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("💎 Gem Packages")
                .font(.title2.weight(.bold))
                .foregroundColor(.neutral900)
            
            LazyVStack(spacing: 16) {
                ForEach(monetizationManager.gemPackages, id: \.id) { package in
                    GemPackageRow(package: package)
                }
            }
            
            VStack(spacing: 12) {
                Text("🎯 Best Value")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.accentGold)
                    .clipShape(Capsule())
                
                Button {
                    monetizationManager.showRoyalPassOffer = true
                } label: {
                    VStack(spacing: 8) {
                        HStack {
                            Text("🏰")
                                .font(.title3)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Royal Pass")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(.white)
                                
                                Text("Unlimited gems + exclusive rewards")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 4) {
                                Text("$9.99")
                                    .font(.title3.weight(.bold))
                                    .foregroundColor(.white)
                                
                                Text("/month")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            BenefitRow(icon: "💎", text: "1000+ gems monthly")
                            BenefitRow(icon: "🎁", text: "Exclusive character skins")
                            BenefitRow(icon: "⚡", text: "No ads + boost events")
                            BenefitRow(icon: "🏆", text: "Early access to new levels")
                        }
                        .padding(.top, 8)
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            colors: [.primaryBlue, .accentGold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(16)
            .background(Color.neutral100)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct GemPackageRow: View {
    let package: GemPackage
    
    @EnvironmentObject var monetizationManager: MonetizationManager
    
    var body: some View {
        Button {
            monetizationManager.purchaseGemPackage(package)
        } label: {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            package.isBestValue 
                            ? LinearGradient(colors: [.accentGold, .primaryBlue], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : Color.primaryBlue
                        )
                        .frame(width: 60, height: 60)
                    
                    Text(package.gems >= 1000 ? "🏰" : "💎")
                        .font(.title3)
                }
                .shadow(color: .primaryBlue.opacity(0.3), radius: 4, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(package.gems) Gems")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.neutral900)
                        
                        if package.bonus > 0 {
                            Text("+\(package.bonus)% BONUS")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.success500)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.success500.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text(package.description)
                        .font(.caption)
                        .foregroundColor(.neutral700)
                    
                    if package.isLimitedTime {
                        Text("⏰ Limited Time Offer")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.error500)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("$\(String(format: "%.2f", package.price))")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primaryBlue)
                    
                    if package.originalPrice > package.price {
                        Text("$\(String(format: "%.2f", package.originalPrice))")
                            .font(.caption)
                            .foregroundColor(.neutral400)
                            .strikethrough()
                    }
                    
                    Text("BUY")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.primaryBlue)
                        .clipShape(Capsule())
                }
            }
            .padding(16)
            .background(Color.neutral100)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        package.isBestValue ? Color.accentGold : Color.clear,
                        lineWidth: package.isBestValue ? 2 : 0
                    )
            )
            .shadow(color: package.isBestValue ? .accentGold.opacity(0.3) : .neutral900.opacity(0.1), 
                   radius: package.isBestValue ? 8 : 4, 
                   x: 0, y: package.isBestValue ? 4 : 2)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct BoostersShopSection: View {
    @EnvironmentObject var monetizationManager: MonetizationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🚀 Power Boosters")
                .font(.title2.weight(.bold))
                .foregroundColor(.neutral900)
            
            LazyVStack(spacing: 16) {
                BoosterPackageRow(
                    icon: "💣",
                    title: "Bomb Pack",
                    description: "Clear 3x3 area instantly",
                    quantity: 5,
                    price: 1.99
                )
                
                BoosterPackageRow(
                    icon: "🔄",
                    title: "Shuffle Pack",
                    description: "Randomize entire board",
                    quantity: 5,
                    price: 1.99
                )
                
                BoosterPackageRow(
                    icon: "⚡",
                    title: "Lightning Pack",
                    description: "Remove any piece type",
                    quantity: 5,
                    price: 2.99
                )
                
                BoosterPackageRow(
                    icon: "🎯",
                    title: "Target Pack",
                    description: "Highlight perfect matches",
                    quantity: 5,
                    price: 2.49
                )
            }
        }
    }
}

struct BoosterPackageRow: View {
    let icon: String
    let title: String
    let description: String
    let quantity: Int
    let price: Double
    
    @EnvironmentObject var monetizationManager: MonetizationManager
    
    var body: some View {
        Button {
            monetizationManager.purchaseBoosterPack(title, quantity: quantity, price: price)
        } label: {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.error500)
                        .frame(width: 50, height: 50)
                    
                    Text(icon)
                        .font(.title2)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundColor(.neutral900)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.neutral700)
                    
                    Text("x\(quantity) pack")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.primaryBlue)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("$\(String(format: "%.2f", price))")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.primaryBlue)
                    
                    Text("BUY")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.primaryBlue)
                        .clipShape(Capsule())
                }
            }
            .padding(16)
            .background(Color.neutral100)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct RoyalPassSection: View {
    @EnvironmentObject var monetizationManager: MonetizationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🏰 Royal Pass")
                .font(.title2.weight(.bold))
                .foregroundColor(.neutral900)
            
            VStack(spacing: 16) {
                if monetizationManager.isRoyalPassActive {
                    RoyalPassStatusView()
                } else {
                    RoyalPassOfferView()
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("🎁 Premium Benefits")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.neutral900)
                    
                    LazyVStack(spacing: 8) {
                        BenefitRow(icon: "💎", text: "1000+ gems every month")
                        BenefitRow(icon: "🎭", text: "Exclusive character skins & animations")
                        BenefitRow(icon: "⚡", text: "Ad-free gameplay experience")
                        BenefitRow(icon: "🚀", text: "2x boost events & challenges")
                        BenefitRow(icon: "🏆", text: "Early access to new levels & features")
                        BenefitRow(icon: "💰", text: "50% discount on all in-app purchases")
                        BenefitRow(icon: "🎯", text: "Priority customer support")
                    }
                }
                .padding(16)
                .background(Color.neutral100)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}

struct RoyalPassStatusView: View {
    @EnvironmentObject var monetizationManager: MonetizationManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("🏰")
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Royal Pass Active")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.success500)
                    
                    Text("Expires: \(monetizationManager.royalPassExpiryDate)")
                        .font(.caption)
                        .foregroundColor(.neutral700)
                }
                
                Spacer()
                
                Text("ACTIVE")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.success500)
                    .clipShape(Capsule())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Monthly Reward Progress")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.neutral700)
                    
                    Spacer()
                    
                    Text("80%")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.primaryBlue)
                }
                
                ProgressView(value: 80, total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: .primaryBlue))
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [.success500.opacity(0.1), .primaryBlue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct RoyalPassOfferView: View {
    @EnvironmentObject var monetizationManager: MonetizationManager
    
    var body: some View {
        Button {
            monetizationManager.showRoyalPassOffer = true
        } label: {
            VStack(spacing: 16) {
                HStack {
                    Text("🏰")
                        .font(.title)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Unlock Royal Pass")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.neutral900)
                        
                        Text("Get premium benefits & exclusive rewards")
                            .font(.caption)
                            .foregroundColor(.neutral700)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("$9.99")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.primaryBlue)
                        
                        Text("/month")
                            .font(.caption)
                            .foregroundColor(.neutral700)
                    }
                }
                
                Text("🎯 START YOUR ROYAL JOURNEY")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.accentGold)
                    .clipShape(Capsule())
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [.primaryBlue.opacity(0.1), .accentGold.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.accentGold, lineWidth: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct SpecialOffersSection: View {
    @EnvironmentObject var monetizationManager: MonetizationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🎯 Special Offers")
                .font(.title2.weight(.bold))
                .foregroundColor(.neutral900)
            
            LazyVStack(spacing: 16) {
                SpecialOfferCard(
                    title: "🎉 Weekend Special",
                    subtitle: "50% OFF Gem Packs",
                    description: "Limited time weekend offer",
                    discount: "50%",
                    originalPrice: "20.00",
                    salePrice: "9.99",
                    timeRemaining: "2d 14h",
                    isUrgent: true
                )
                
                SpecialOfferCard(
                    title: "🎁 First Time Buyer",
                    subtitle: "Welcome Bonus Pack",
                    description: "Perfect starter pack for new players",
                    discount: "70%",
                    originalPrice: "15.99",
                    salePrice: "4.99",
                    timeRemaining: "23h",
                    isUrgent: false
                )
                
                SpecialOfferCard(
                    title: "🎄 Holiday Mega Pack",
                    subtitle: "Gems + Boosters + Characters",
                    description: "Best value pack of the year",
                    discount: "60%",
                    originalPrice: "49.99",
                    salePrice: "19.99",
                    timeRemaining: "5d",
                    isUrgent: false
                )
            }
        }
    }
}

struct SpecialOfferCard: View {
    let title: String
    let subtitle: String
    let description: String
    let discount: String
    let originalPrice: String
    let salePrice: String
    let timeRemaining: String
    let isUrgent: Bool
    
    @EnvironmentObject var monetizationManager: MonetizationManager
    
    var body: some View {
        Button {
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline.weight(.bold))
                            .foregroundColor(.neutral900)
                        
                        Text(subtitle)
                            .font(.title3.weight(.bold))
                            .foregroundColor(.primaryBlue)
                        
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.neutral700)
                    }
                    
                    Spacer()
                    
                    if isUrgent {
                        Text("🔥")
                            .font(.title2)
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("$\(originalPrice)")
                                .font(.headline)
                                .foregroundColor(.neutral400)
                                .strikethrough()
                            
                            Text("SAVE \(discount)")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.error500)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.error500.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        
                        Text("$\(salePrice)")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.primaryBlue)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("⏰")
                            .font(.caption)
                        
                        Text(timeRemaining)
                            .font(.caption.weight(.bold))
                            .foregroundColor(isUrgent ? .error500 : .neutral700)
                    }
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: isUrgent 
                    ? [.error500.opacity(0.1), .primaryBlue.opacity(0.1)]
                    : [.primaryBlue.opacity(0.1), .accentGold.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isUrgent ? Color.error500 : Color.accentGold,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.body)
            
            Text(text)
                .font(.body)
                .foregroundColor(.neutral700)
            
            Spacer()
        }
    }
}

struct RoyalPassOfferModal: View {
    @EnvironmentObject var monetizationManager: MonetizationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPlan: RoyalPassPlan = .monthly
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        Text("🏰")
                            .font(.system(size: 80))
                        
                        Text("Royal Pass")
                            .font(.title.bold())
                            .foregroundColor(.neutral900)
                        
                        Text("Unlock premium benefits and exclusive rewards")
                            .font(.body)
                            .foregroundColor(.neutral700)
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(spacing: 12) {
                        Text("Choose Your Plan")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.neutral900)
                        
                        HStack(spacing: 12) {
                            PlanCard(
                                plan: .monthly,
                                isSelected: selectedPlan == .monthly,
                                onSelect: { selectedPlan = .monthly }
                            )
                            
                            PlanCard(
                                plan: .yearly,
                                isSelected: selectedPlan == .yearly,
                                onSelect: { selectedPlan = .yearly }
                            )
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("🎁 What's Included")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.neutral900)
                        
                        LazyVStack(spacing: 12) {
                            BenefitRow(icon: "💎", text: "1000+ gems delivered monthly")
                            BenefitRow(icon: "🎭", text: "Exclusive character skins & animations")
                            BenefitRow(icon: "⚡", text: "Completely ad-free experience")
                            BenefitRow(icon: "🚀", text: "2x boost events & challenges")
                            BenefitRow(icon: "🏆", text: "Early access to new levels")
                            BenefitRow(icon: "💰", text: "50% discount on all purchases")
                            BenefitRow(icon: "🎯", text: "Priority customer support")
                        }
                    }
                    .padding(20)
                    .background(Color.neutral100)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Button {
                        monetizationManager.purchaseRoyalPass(plan: selectedPlan)
                        dismiss()
                    } label: {
                        VStack(spacing: 8) {
                            Text("START ROYAL PASS")
                                .font(.headline.weight(.bold))
                                .foregroundColor(.white)
                            
                            Text("\(selectedPlan.priceString) - Cancel anytime")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.primaryBlue, .accentGold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.neutral700)
                    }
                }
            }
        }
    }
}

struct PlanCard: View {
    let plan: RoyalPassPlan
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                Text(plan == .monthly ? "📅" : "📆")
                    .font(.title)
                
                VStack(spacing: 4) {
                    Text(plan == .monthly ? "Monthly" : "Yearly")
                        .font(.headline.weight(.bold))
                        .foregroundColor(isSelected ? .white : .neutral900)
                    
                    Text(plan.priceString)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.9) : .neutral700)
                }
                
                if plan == .yearly {
                    Text("SAVE 20%")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.accentGold)
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(
                isSelected 
                ? LinearGradient(colors: [.primaryBlue, .accentGold], startPoint: .topLeading, endPoint: .bottomTrailing)
                : Color.neutral100
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.accentGold : Color.clear,
                        lineWidth: isSelected ? 3 : 0
                    )
                    .shadow(color: isSelected ? .accentGold.opacity(0.5) : .clear, radius: isSelected ? 8 : 0, x: 0, y: isSelected ? 4 : 0)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}


enum ShopCategory: String, CaseIterable {
    case gems = "Gems"
    case boosters = "Boosters"
    case royalPass = "Royal Pass"
    case specialOffers = "Special"
}

struct GemPackage: Identifiable {
    let id = UUID()
    let gems: Int
    let bonus: Int
    let price: Double
    let originalPrice: Double?
    let description: String
    let isBestValue: Bool
    let isLimitedTime: Bool
}

enum RoyalPassPlan {
    case monthly
    case yearly
    
    var priceString: String {
        switch self {
        case .monthly:
            return "$9.99/month"
        case .yearly:
            return "$99.99/year"
        }
    }
}

#Preview {
    ShopScreenView()
        .environmentObject(MonetizationManager())
        .environmentObject(GameManager())
        .environmentObject(AdManager())
}